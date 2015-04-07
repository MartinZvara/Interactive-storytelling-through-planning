import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Random;
import java.util.Scanner;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author Martin Zvara
 */
public class Planner {

    static File clingo, domain;
    static String[] names = new String[]{"Absentation.lp", "ViolationOfInterdictionn.lp", "Transition-Proposal.lp", "FirstFunctionOfDonor.lp", "Guidance.lp",
        "Struggle.lp", "Branding.lp", "Victory.lp", "Return.lp", "UnfoundedClaims.lp", "Recognition.lp", "Wedding.lp"};

    public static void parsePlan(String action, TreeMap<Integer, String> sentences) {
        StringBuilder sentence = new StringBuilder();
        StringBuilder word = new StringBuilder();
        int i = 0, begin = 9, end = 9;
        while (end < action.length() - 1) {
            while (action.charAt(end) != ',' && action.charAt(end) != '(' && action.charAt(end) != ')') {
                end++;
            }
            if (i == 0) {
                word.append(action.subSequence(begin, end));
                word.append(" ");
                i++;
            } else if (i == 1) {
                sentence.append(action.subSequence(begin, end));
                sentence.append(" ");
                sentence.append(word);
                i++;
            } else if (i == 2) {
                sentence.append(action.subSequence(begin, end));
                sentence.append(" ");
                if (word.toString().contains("tell")) {
                    sentence.append("that ");
                }
                word.delete(0, word.length());
                i = 0;
            }
            begin = end + 1;
            end++;
            if (end >= action.length() - 1) {
                if (word.length() > 0) {
                    sentence.append(word);
                    word.delete(0, word.length());
                }
            }
        }
        sentences.put(action.charAt(7) - 48, sentence.toString());
        //System.out.println(sentence.toString());
    }

    /**
     * This method run given plan with domain in clingo and find appertaining actions.  
     *
     * @param plan - 
     * @param domain -
     * @return ArrayList of last holds of given plan.
     */
    public static ArrayList<String> findPlan(File domain, File plan) {
        ArrayList<String> result = new ArrayList<>();
        ArrayList<TreeMap<Integer, ArrayList<String>>> fluents = new ArrayList<>();
        ArrayList<ArrayList<String>> occurs = new ArrayList<>();
        TreeMap<Integer, String> sentences = new TreeMap<>();
        Random rnd = new Random();
        int pCounter = -1;
        try {
            String[] cmd = new String[]{clingo.getAbsolutePath(), domain.getAbsolutePath(), plan.getAbsolutePath(), "-n 0"};
            Process p = Runtime.getRuntime().exec(cmd);

            String line = "";
            Scanner s = new Scanner(p.getInputStream());
            int state;
            while (s.hasNextLine()) {
                line = s.next();
                //System.out.println(line);
                if (line.equals("SATISFIABLE") || line.equals("UNSATISFIABLE")) {
                    break;
                }
                if (line.contains("Answer")) {
                    occurs.add(new ArrayList<String>());
                    fluents.add(new TreeMap<Integer, ArrayList<String>>());
                    pCounter++;
                }
                //debug
                if (line.contains("occurs")) {
                    //System.out.println(line); //- actions
                    //parse plan
                    occurs.get(pCounter).add(line);
                }
                if (line.contains("holds")) {
                    //System.out.println(line); //- fluents
                    state = Integer.parseInt(line.charAt(6) + "");
                    if (fluents.get(pCounter).containsKey(state)) {
                        fluents.get(pCounter).get(state).add(line.replace(line.charAt(6), '0'));
                    } else {
                        fluents.get(pCounter).put(state, new ArrayList<String>());
                        fluents.get(pCounter).get(state).add(line.replace(line.charAt(6), '0'));
                    }
                }
            }
            if (pCounter == -1) { //ziadny plan
                return result;
            } else {
            //actions.add(occurs);
                //System.out.println(fluents.get(fluents.lastKey()));
                pCounter = rnd.nextInt(fluents.size());
                for (String action : occurs.get(pCounter)) {
                    parsePlan(action, sentences);
                }
                if (!fluents.get(pCounter).isEmpty()) {
                    result.addAll(fluents.get(pCounter).get(fluents.get(pCounter).lastKey()));
                    for (String sentence : sentences.values()) {
                        System.out.println(sentence);
                    }
                    return result;
                }
            }
        } catch (IOException ex) {
            Logger.getLogger(Planner.class.getName()).log(Level.SEVERE, null, ex);
        }
        return result;
    }

    /**
     * This method generate plan according given non complete plan.  
     *
     * @param plan - non complete logic program
     * @param initially - initial fluents
     * @param counter - length of plan
     * @return updated plan
     */
    public static File generatePlan(File plan, ArrayList<String> initially, int counter) {
        //int counter = 1;
        if (initially != null) {
            File ePlan = new File("e" + plan.getName());
            Scanner s;
            try {
                ePlan.createNewFile();
                String line;
                s = new Scanner(plan);
                PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(ePlan)));
                while (s.hasNextLine()) {
                    line = s.nextLine();
                    if (line.contains("INITIAL STATE")) { //write last fluents from prev. plan
                        writer.write(line + "\n");
                        writer.write(s.nextLine() + "\n");
                        for (String fluent : initially) {
                            writer.write(fluent + ".\n");
                        }
                    } else if (line.contains("#const")) { //write length of plan  
                        writer.write(line + counter + ".\n");
                    } else {
                        writer.write(line + "\n");
                    }
                }
                s.close();
                writer.close();
                return ePlan;
            } catch (FileNotFoundException ex) {
                Logger.getLogger(Planner.class.getName()).log(Level.SEVERE, null, ex);
            } catch (IOException ex) {
                Logger.getLogger(Planner.class.getName()).log(Level.SEVERE, null, ex);
            }
        } else {
            return plan;
        }
        return null;
    }

    public static void main(String[] args) {
        clingo = new File("clingo.exe");
        domain = new File("domain.dl");
        ArrayList<ArrayList<String>> fluents = new ArrayList<>();
        fluents.add(new ArrayList<String>());

        for (int i = 0; i < names.length; i++) {
            int j = 0;
            fluents.add(new ArrayList<String>());
            while (fluents.get(i + 1).isEmpty()) {
                fluents.get(i + 1).addAll(findPlan(domain, generatePlan(new File(names[i]), fluents.get(i), j++)));
            }
        }
    }
}
