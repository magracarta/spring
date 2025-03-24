<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 입출금전표처리 > 입출금전표등록 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// Q&A 14323 적요에 "센터_" 추가. 2022.11.17 김상덕
		var centerPreName = "";
		<%--if('CENTER' == "${SecureUser.org_type}") {--%>
		if(${page.fnc.F00799_001 eq 'Y'}) {
			centerPreName = "${SecureUser.org_name}".substring(0, 2)+"_";
		}

		// 2022-12-07 황빛찬 (SR : 14503) 유상부품대 연동 추가.
		var partCostAmt;

		$(document).ready(function() {
			fnInitPage();
		});

		function fnInitPage() {

			fnCallPageCheck();
			var custNo = "${inputParam.cust_no}";
			// 파라미터 유무에 따라 조회
			if(custNo != "") {
				$M.setValue("cust_no", custNo);
				goCustInfo();
			}

			// 매출상세에서 입출금전표처리 오픈 시 파라미터 세팅
			var machineUsedNo = "${inputParam.machine_used_no}";
			var rentalDocNo = "${inputParam.rental_doc_no}";
    		var jobReportNo = "${inputParam.job_report_no}";
    		var partSaleNo = "${inputParam.part_sale_no}";
    		var rentalMachineNo = "${inputParam.rental_machine_no}";
    		var machineDocNo = "${inputParam.machine_doc_no}";

    		if(machineUsedNo != "") {
				$M.setValue("machine_used_no", machineUsedNo);
				$(".param_name").text("※연동 중고장비 : " + machineUsedNo);
			} else if(rentalDocNo != ""){
				$M.setValue("rental_doc_no", rentalDocNo);
				$(".param_name").text("※연동 렌탈 : " + rentalDocNo);
			} else if(jobReportNo != ""){
				$M.setValue("job_report_no", jobReportNo);
				$(".param_name").text("※연동 정비 : " + jobReportNo);
			} else if(partSaleNo != ""){
				$M.setValue("part_sale_no", partSaleNo);
				$(".param_name").text("※연동 수주 : " + partSaleNo);
			} else if(rentalMachineNo != ""){
				$M.setValue("rental_machine_no", rentalMachineNo);
				$(".param_name").text("※연동 렌탈장비 : " + rentalMachineNo);
			} else if (machineDocNo != "") {
				// 2022-12-07 황빛찬 (SR : 14503) 유상부품대 연동 추가.
				$M.setValue("machine_doc_no", machineDocNo);
				$(".param_name").text("※연동 계약품의서 : " + machineDocNo);
				partCostAmt = "${inputParam.result_part_cost_amt}";
			}

			if($M.getValue("popup_yn") == "Y") {
				$("#_fnList").addClass("dpn");
				$("#popupBtn").addClass("dpn");
			} else {
				$("#_fnClose").addClass("dpn");
			}

		}

		function fnCallPageCheck() {

			var callPageSeq  = "${inputParam.call_page_seq}";
			var checkPageSeq = ${check_page_seq};

			if(callPageSeq == 5743) {	// [매입거래정산관리]에서 팝업 호출했을 경우..
				$M.setValue("inout_type_cd", "02");
				$M.setValue("doc_amt", "${inputParam.total_amt}");
				$M.setValue("total_amt", $M.getValue("doc_amt"));
				$M.setValue("inout_amt", $M.getValue("doc_amt"));

			} else {
				if (callPageSeq != checkPageSeq) {
					return;
				}
				var dealTypeRv = "${inputParam.deal_type_rv}";

				var param = {
					call_page_seq 	: callPageSeq,
					s_inout_type_io : "${inputParam.inout_type_io}",
					s_acc_type_cd   : "${inputParam.acc_type_cd}",
					s_deal_type_rv  : dealTypeRv
				};


				$M.setValue("inout_type_cd", "01");		// [자동화개발]- 출금도 입금으로 나오게!(근데 출금시 입금으로 나오되 금액은 마이너스로 <황다은>
				$M.setValue("acc_type_cd", param.s_acc_type_cd);
				$M.setValue("inout_dt", "${inputParam.deal_dt}");

				var ibk_iss_acct_his_seq =  "${inputParam.ibk_iss_acct_his_seq}"
				var ibk_rcv_vacct_reco_seq =  "${inputParam.ibk_rcv_vacct_reco_seq}"
				var ibk_iss_stockacct_his_seq =  "${inputParam.ibk_iss_stockacct_his_seq}"

				// [재호] 23.08.28 : 증권계좌 로직 추가
				// - ibk 입출금 내역
				if(ibk_iss_acct_his_seq) {
					param.s_ibk_iss_acct_his_seq = ibk_iss_acct_his_seq;
				}
				// - ibk 가상계좌 내역
				else if(ibk_rcv_vacct_reco_seq) {
					param.s_ibk_rcv_vacct_reco_seq = ibk_rcv_vacct_reco_seq;
				}
				// - ibk 증권계좌 내역
				else if(ibk_iss_stockacct_his_seq) {
					param.s_ibk_iss_stockacct_his_seq = ibk_iss_stockacct_his_seq;
				}

				<%--if (dealTypeRv == 'R' ) {--%>
				<%--	param.s_ibk_iss_acct_his_seq   = "${inputParam.ibk_iss_acct_his_seq}";--%>
				<%--} else if(dealTypeRv == 'V' ) {--%>
				<%--	param.s_ibk_rcv_vacct_reco_seq = "${inputParam.ibk_rcv_vacct_reco_seq}";--%>
				<%--}--%>

				$M.goNextPageAjax("/cust/cust0301p03/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							$(".deposit_bank").removeClass("dpn");
							$(".deposit_cash").addClass("dpn");
							$(".deposit_card").addClass("dpn");
							$(".deposit_replace").addClass("dpn");
							$(".deposit_billin").addClass("dpn");
							fnSetBankInfo(result.list[0]); // 단일컬럼
							if(param.s_inout_type_io == "O") {
								$M.setValue("doc_amt",$M.getValue("doc_amt")*(-1));
								$M.setValue("inout_amt",$M.getValue("inout_amt")*(-1));
								$M.setValue("total_amt",$M.getValue("total_amt")*(-1));
							}
						}
					}
				);
			}
		}

		function fnClientPayPageCheck() {

		}

		function goCustInfoClick() {
			var param = {
					s_cust_no : $M.getValue("cust_name"),
					"s_cust_yn" : "Y"
			};
			openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
		}

		function goCustInfo() {
			var param = {
					s_cust_no : $M.getValue("cust_no"),
					"s_sort_key" : "c.cust_name",
					"s_sort_method" : "desc",
			};
			$M.goNextPageAjax("/cust/cust020101/searchCust", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#cust_name").blur();
						var list = result.list;
						switch(list.length) {
							case 0 :
								$M.clearValue({field:["cust_name"]});
								break;
							case 1 :
								var row = list[0];
								fnSetCustInfo(row);
								break;
							default :
								openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
							break;
						}
					}
				}
			);
		}

		function fnSetCustInfo(row) {
			var param = {
					"cust_no" : row.cust_no
			}
			isCust = true;
			$M.goNextPageAjax(this_page + "/custInfo", $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			var list = result.list;
		    			$M.setValue(list);
		    			var param = {
		    					cust_no : list.cust_no,
		    					cust_name : list.cust_name,
		    					cust_hp_no : $M.phoneFormat(list.hp_no),
		    					cust_fax_no : list.fax_no,
		    					breg_seq : list.breg_seq,
		    					breg_name : list.breg_name,
		    					breg_no : list.breg_no,
		    					breg_rep_name : list.breg_rep_name,
		    					breg_cor_type : list.breg_cor_type,
		    					breg_cor_part : list.breg_cor_part,
		    					post_no : list.biz_post_no,
		    					addr1 : list.biz_addr1,
		    					addr2 : list.biz_addr2,
		    					sale_mem_no : list.sale_mem_no,
		    					misu_amt : list.misu_amt
		    				}
		    			console.log(" ---> ", param);
		    			$M.setValue(param);
		    			// 개인정보동의
						// goSearchPrivacyAgree();
					}
				}
			);
		}

		// 개인정보동의 팝업
// 		function goSearchPrivacyAgree() {
// 			var param = {
// 				cust_no : $M.getValue("cust_no")
// 			}
// 			$M.goNextPageAjax("/comp/comp0306/search", $M.toGetParam(param), {method : 'get'},
// 				function(result){
// 					if(result.success) {
// 						var custInfo = result.custInfo;
// 						if (custInfo.personal_yn != "Y") {
// 							if (confirm("개인정보 동의사항을 확인하세요") == true) {
// 								openPrivacyAgreePanel('fnSetPrivacy', $M.toGetParam(param));
// 							}
// 						}
// 					}
// 				}
// 			);
// 		}

// 		// 개인정보 동의 세팅
// 		function fnSetPrivacy(data) {
// 			alert(JSON.stringify(data));
// 		}

		// 고객상세 팝업
		function goCustDetailInfo() {
			var custNo = $M.getValue('cust_no');
			if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
			var param = {
					"cust_no" : $M.getValue("cust_no")
			}
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
			$M.goNextPage('/cust/cust0102p01/', $M.toGetParam(param), {popupStatus : poppupOption});
		}
	    // 고객조회 결과
	    function setCustInfo(row) {
	       alert(JSON.stringify(row));
	    }

	    // 사업자명세조회
		function fnSearchBregSpec() {
	    	if($M.getValue("cust_no") == "") {
	    		alert("고객명을 먼저 검색해주세요.");
	    		return false;
	    	}
			var param = {
					"s_cust_no" : $M.getValue("cust_no")
			};
			openSearchBregSpecPanel('fnSetBregSpec', $M.toGetParam(param));
		}

		function fnSetBregSpec(data) {
		}


		// 사업자명세 정보 call back
	    function fnSetBregSpec(row) {
	        var param = {
	        	"breg_name" : row.breg_name,
	        	"breg_no" : row.breg_no,
	        	"breg_rep_name" : row.breg_rep_name,
	        	"breg_cor_type" : row.breg_cor_type,
	        	"breg_cor_part" : row.breg_cor_part,
	        	"breg_seq" : row.breg_seq,
	        	"biz_post_no" : row.biz_post_no,
	        	"biz_addr1" : row.biz_addr1,
	        	"biz_addr2" : row.biz_addr2,
	        	"biz_addr" : row.biz_post_no + ' ' + row.biz_addr1 + ' ' + row.biz_addr2
	        };
	        $M.setValue(param);
	    }


	    // 매출자료참조 팝업
	    function goSaleReference() {
	    	if($M.getValue("sale_inout_doc_no") != "") {
	    		alert("전표에서 넘어온 자료입니다.");
	    		return false;
	    	}
	    	var params = {
	    			"parent_js_name" : "setSaleInfo"
	    	};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=500, left=0, top=0";
			$M.goNextPage('/cust/cust0203p02', $M.toGetParam(params), {popupStatus : popupOption});
	    }

	    // 매출자료참조 클릭 시 해당 고객 조회
	    function setSaleInfo(data) {
	    	$M.setValue("cust_name", data.cust_name);
	    	$M.setValue("cust_no", data.cust_no);
	    	$M.setValue("part_sale_no", data.part_sale_no);
	    	$M.setValue("job_report_no", data.job_report_no);
	    	$M.setValue("rental_doc_no", data.rental_doc_no);
	    	$M.setValue("machine_used_no", data.machine_used_no);
	    	$M.setValue("rental_machine_no", data.rental_machine_no);
	    	$M.setValue("sale_inout_doc_no", data.inout_doc_no);
	    	goCustInfo();
// 	    	goCustInfoClick();
	    	//fnSetCustInfo(data.cust_no);
	    }

	    function fnList() {
	    	history.back();
	    }

		   // 문자발송
		function fnSendSms() {
			  var param = {
					  name : $M.getValue("cust_name"),
					  hp_no : $M.getValue("cust_hp_no")
			  }
			  	openSendSmsPanel($M.toGetParam(param));
		}

		// 계정구분에 따라 form 디자인 변경
		function fnChangeDepositForm() {
			var params = {
		    		"acc_type_cd" : $M.getValue("acc_type_cd"),
		    		"cust_no" : $M.getValue("cust_no"),
		    		"deposit_dt" : $M.getValue("inout_dt"),
		    		"amt" : $M.getValue("doc_amt"),
		    		"parent_js_name" : ""

		    };
			fnReset();
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=360, height=330, left=0, top=0";
			switch($("#acc_type_cd").val()) {
			case "1" : $(".deposit_billin").addClass("dpn");
					    $(".deposit_cash").removeClass("dpn");
					    $(".deposit_card").addClass("dpn");
					    $(".deposit_replace").addClass("dpn");
					    $(".deposit_bank").addClass("dpn");
						// Q&A 14323 적요에 "센터_" 추가. 2022.11.17 김상덕
						$M.setValue("desc_text", centerPreName);
					    break;
			case "2" : $(".deposit_billin").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_card").addClass("dpn");
						$(".deposit_replace").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
						params.inout_type_io = $M.getValue("inout_type_io");
						params.parent_js_name = "fnSetBillinInfo";
						$M.goNextPage('/cust/cust0301p04', $M.toGetParam(params), {popupStatus : popupOption});
						break;
			case "3" : $(".deposit_bank").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_card").addClass("dpn");
						$(".deposit_replace").addClass("dpn");
						$(".deposit_billin").addClass("dpn");
						var amt = $M.toNum($M.getValue("doc_amt"));
						var inoutType = "";
						if($M.getValue("inout_type_cd") == "01") {
							inoutType = amt >= 0 ? "I" : "O";
						} else if($M.getValue("inout_type_cd") == "02") {
							inoutType = amt >= 0 ? "O" : "I";
						}
						params.inout_type_io = inoutType;
						params.parent_js_name = "fnSetBankInfo";
						var popupOption = "";
						$M.goNextPage('/cust/cust0301p03', $M.toGetParam(params), {popupStatus : popupOption});
						break;
			case "4" : $(".deposit_card").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
						$(".deposit_replace").addClass("dpn");
						$(".deposit_billin").addClass("dpn");
						params.parent_js_name = "fnSetCardInfo";
						$M.goNextPage('/cust/cust0301p04', $M.toGetParam(params), {popupStatus : popupOption});
						break;
			case "5" : $(".deposit_replace").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
						$(".deposit_card").addClass("dpn");
						$(".deposit_billin").addClass("dpn");
						params.parent_js_name = "fnSetReplaceInfo";
						$M.goNextPage('/cust/cust0301p04', $M.toGetParam(params), {popupStatus : popupOption});
						break;
			}
		}

		function fnReset() {
			var setParam = {
					// 은행
					'site_no' : '',
					'ibk_iss_acct_his_seq' : '',
					'ibk_rcv_vacct_reco_seq' : '',
					'ibk_iss_stockacct_his_seq' : '',
					'out_tx_amt' : '',
					'ibk_bank_name' :  '',
					'ibk_bank_cd' : '',
					'acct_no' : '',
					'account_no' : '',
					'acct_txday' : '',
					'tx_amt' : '',
					'jeokyo' : '',

					// 카드
					'card_cmp_name' : '',
					'card_cmp_cd' : '',
					'approval_no' : '',

					// 어음
					'bill_no' :  '',
					'billin_no' :  '',
					'end_dt' : '',
					'corp_cust_name' : '',

					// 대체
					'in_replace_acnt_cd' : '',
					'in_replace_acnt_name' : '',
					'replace_cust_name' : '',
					'replace_cust_no' : '',

					// 비고
					'desc_text' : '',

			};
			$M.setValue(setParam);
		}

		// 어음 데이터 셋팅
		function fnSetBillinInfo(data) {
			$M.setValue("bill_no", data.bill_no);
			$M.setValue("billin_no", data.billin_no);
			$M.setValue("end_dt", data.end_dt);
			$M.setValue("corp_cust_name", data.corp_cust_name);
			$M.setValue("desc_text", data.corp_cust_name+ "/" + data.bill_no + "/" + $M.dateFormat(data.end_dt, "yyyy-MM-dd"));

		}

		// 은행 데이터 셋팅
		function fnSetBankInfo(data) {
			$M.setValue("ibk_bank_name", data.ibk_bank_name);
			$M.setValue("ibk_bank_cd", data.ibk_bank_cd);
			$M.setValue("account_no", data.account_no);
			$M.setValue("acct_no", data.acct_no);
			$M.setValue("acct_txday", data.deal_dt);
			$M.setValue("acct_txday_seq", data.acct_txday_seq);
			if(data.in_tx_amt == "") {
				$M.setValue("tx_amt", $M.setComma(data.out_tx_amt));
			} else {
				$M.setValue("tx_amt", $M.setComma(data.in_tx_amt));
			}
			$M.setValue("jeokyo", data.deposit_name);
			$M.setValue("site_no", data.site_no);
			$M.setValue("ibk_iss_acct_his_seq", data.ibk_iss_acct_his_seq);
			$M.setValue("ibk_rcv_vacct_reco_seq", data.ibk_rcv_vacct_reco_seq);
			$M.setValue("ibk_iss_stockacct_his_seq", data.ibk_iss_stockacct_his_seq);
			$M.setValue("inout_type_io", data.inout_type_io);


			var bankName = data.ibk_bank_name.trim();
			var descText = bankName + "/" + data.account_no + "/" + data.deposit_name + "/" + $M.setComma($M.getValue("tx_amt"))
			$M.setValue("desc_text", descText);
			$M.setValue("doc_amt", $M.setComma($M.getValue("tx_amt")));
			fnChangeTxAmt();
			fnCalcAmt();
		}

		// 카드 데이터 셋팅
		function fnSetCardInfo(data) {
			$M.setValue("approval_no", data.approval_no);
			$M.setValue("card_cmp_cd", data.card_cmp_cd);
			$M.setValue("card_cmp_name", data.card_cmp_name);
			$M.setValue("desc_text", centerPreName + data.card_cmp_name+ "/" + data.approval_no);
		}

		// 대체 데이터 셋팅
		function fnSetReplaceInfo(data) {
			// 추후 bodyno에 관련된 페이지 나올 시 수정해야함
			// 계정과목명  "서비스충당부채"시 로직은 계정과목에 없기에 삭제
			$M.setValue("in_replace_acnt_name", data.in_replace_acnt_name);
			$M.setValue("in_replace_acnt_cd", data.in_replace_acnt_cd);
			$M.setValue("replace_cust_no", data.replace_cust_no);
			$M.setValue("replace_cust_name", data.replace_cust_name);
			$M.setValue("desc_text", data.in_replace_acnt_name+ "/" + data.replace_cust_name + " 대체");
		}

		function fnChangeTxAmt() {
			if($M.getValue("inout_type_io") == "O") {
				$("#inout_type_name").text("출금액");
				$("#inout_type_mem_name").text("출금자");
				$("#inout_type_dt").text("출금일자");
			} else {
				$("#inout_type_name").text("입금액");
				$("#inout_type_mem_name").text("입금자");
				$("#inout_type_dt").text("입금일자");
			}
		}

	    function goSave() {
			// 2022-12-07 황빛찬 (SR : 14503) 유상부품대 연동 추가.
			if (partCostAmt != undefined) {
				var docAmt = $M.toNum($M.getValue("doc_amt"));
				if (docAmt > partCostAmt) {
					alert("남은 유상부품대 : " + $M.numberFormat(partCostAmt) + "원 으로, 입금액이 더 클 수 없습니다.");
					$("#doc_amt").focus();
					return false;
				}
			}

	    	var frm = document.main_form;
		  	// validation check
	     	if($M.validation(frm) === false) {
	     		return;
	     	};

			switch($("#acc_type_cd").val()) {
			// '어음'일 시 입금자에 발행처 저장, 계좌번호에 어음번호 저장
			case "2" :  if($M.validation(frm, {field:["billin_no", "bill_no", "end_dt"]}) == false) {
							return;
						};
						$M.setValue("acct_no", $M.getValue("bill_no"));
						$M.setValue("jeokyo", $M.getValue("corp_cust_name"));
						break;
			// '은행'일 시 만기일자에 입금일자 저장 (acctNo에 계좌번호 저장)
			case "3" :
						if($M.getValue("ibk_iss_acct_his_seq") != "") {
							$M.setValue("ibk_gubun", "H");
							if($M.validation(frm, {field:["ibk_iss_acct_his_seq"]}) == false) {
								return;
							};
						} else if ($M.getValue("ibk_rcv_vacct_reco_seq") != "") {
							$M.setValue("ibk_gubun", "R");
							if($M.validation(frm, {field:["ibk_rcv_vacct_reco_seq"]}) == false) {
								return;
							};
						} else if ($M.getValue("ibk_iss_stockacct_his_seq") != "") {
							$M.setValue("ibk_gubun", "R");
							if($M.validation(frm, {field:["ibk_iss_stockacct_his_seq"]}) == false) {
								return;
							};
						}
// 						$M.setValue("end_dt", $M.getValue("acct_txday"));
						if($M.getValue("acct_txday") != $M.getValue("inout_dt")) {
							alert("입금일자를 확인 후 처리해주세요.");
							return false;
						}
						var docAmt = $M.toNum($M.getValue("doc_amt"));
						var txAmt = $M.toNum($M.getValue("tx_amt"));
						if(docAmt > txAmt) {
							alert("입금액을 확인 후 처리하세요.");
							return false;
						}
						break;
			// '카드'일 시 은행명에 카드사 저장
			case "4" :  if($M.validation(frm, {field:["card_cmp_name", "card_cmp_cd", "approval_no"]}) == false) {
							return;
						};
						$M.setValue("ibk_bank_cd", $M.getValue("card_cmp_cd"));
						$M.setValue("ibk_bank_name", $M.getValue("card_cmp_name"));
						break;
			// '대체'일 시
			case "5" :  if($M.validation(frm, {field:["in_replace_acnt_cd", "replace_cust_no"]}) == false) {
							return;
						};
						break;
			}
			var inoutNm = "";
			if($M.getValue("inout_type_cd") == "02") {
				inoutNm = "출금";
			} else if ($M.getValue("inout_type_cd") == "01") {
				inoutNm = "입금";
			}
			$M.setValue("count_remark", inoutNm);
			if($M.getValue("inout_type_io") == "") {
				$M.setValue("inout_type_io", "I");
			}

			// [자동화추가개발][황다은]- 매입거래정산관리 페이지에서 출금전표 끊을 시 파라미터 내용 추가
			if("${inputParam.call_page_seq}" == 5743) {
				$M.setValue(frm, "call_page_seq", 5743);
				$M.setValue(frm, "inout_doc_no_group_str", "${inputParam.inout_doc_no_str}");
				$M.setValue(frm, "req_pay_amt", "${inputParam.total_amt}");
			}

			var checkDocAmt = $M.toNum($M.getValue("doc_amt"));
			var msg = checkDocAmt == 0 ? "현재 입금액이 0원입니다.\n그래도 저장 하시겠습니까?" : "저장하시겠습니까?";

			$M.goNextPageAjaxMsg(msg, this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							if($M.getValue("popup_yn") != "Y") {
								$M.goNextPage("/cust/cust0203");
							} else {
								$M.getValue("call_page_seq") == 5743 ? window.opener.goSearch() : opener.location.reload();
								fnClose();
							}
						}
					}
				);

	    }

		// 합계금액 계산
		function fnCalcAmt() {
			var calDocAmt = $M.toNum($M.getValue("doc_amt"));
			var discount = 0;
			var totalAmt = 0;

			if($M.getValue("discount_amt") != "") {
				discount = calDocAmt + ($M.toNum($M.getValue("discount_amt")));
				totalAmt = discount;
			} else {
				totalAmt = calDocAmt;
			};

			$M.setValue("total_amt", totalAmt);
			$M.setValue("inout_amt", $M.getValue("doc_amt"));

		}

		function fnClose() {
			window.close();
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="breg_seq" name="breg_seq"> <!-- 사업자일련번호 -->
<input type="hidden" id="inout_money_type_cd" name="inout_money_type_cd" value="PART"> <!-- 입출금타입코드 -->
<input type="hidden" id="billin_no" name="billin_no">	<!-- 어음관리번호 -->
<input type="hidden" id="ibk_iss_acct_his_seq" name="ibk_iss_acct_his_seq">	<!-- 계좌 seq -->
<input type="hidden" id="ibk_rcv_vacct_reco_seq" name="ibk_rcv_vacct_reco_seq">	<!-- 가상계좌 seq -->
<input type="hidden" id="ibk_iss_stockacct_his_seq" name="ibk_iss_stockacct_his_seq">	<!-- 증권계좌 seq -->
<!-- 입출금전표처리만 따로 히든 관리 -->
<input type="hidden" id="inout_gubun" name="inout_gubun">	<!-- 은행 입출구분 -->
<input type="hidden" id="ibk_bank_cd" name="ibk_bank_cd">	<!-- 은행코드 -->
<input type="hidden" id="card_cmp_cd" name="card_cmp_cd">	<!-- 카드사코드 -->
<input type="hidden" id="acct_no" name="acct_no">	<!-- 계좌번호 -->
<input type="hidden" id="in_replace_acnt_cd" name="in_replace_acnt_cd">	<!-- 대체계정코드 -->
<input type="hidden" id="replace_cust_no" name="replace_cust_no">	<!-- 대체고객번호 -->
<input type="hidden" id="count_remark" name="count_remark">	<!-- 품목외건수 -->
<input type="hidden" id="inout_type_io" name="inout_type_io"> <!-- 입출구분 -->
<input type="hidden" id="coupon_amt" name="coupon_amt" format="decimal" value="0"> <!-- 쿠폰금액 -->
<input type="hidden" id="ibk_gubun" name="ibk_gubun"> <!-- 계좌구분 -->
<input type="hidden" id="part_sale_no" name="part_sale_no"> <!-- 수주번호 -->
<input type="hidden" id="job_report_no" name="job_report_no"> <!-- 정비번호 -->
<input type="hidden" id="rental_doc_no" name="rental_doc_no"> <!-- 렌탈번호 -->
<input type="hidden" id="machine_used_no" name="machine_used_no"> <!-- 중고장비번호 -->
<input type="hidden" id="rental_machine_no" name="rental_machine_no"> <!-- 임대장비번호 -->
<input type="hidden" id="popup_yn" name="popup_yn" value="${inputParam.popup_yn}">
<input type="hidden" id="sale_inout_doc_no" name="sale_inout_doc_no" value="${inputParam.sale_inout_doc_no}">  <!-- 입금액 반영할 전표번호 -->

<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
					<div class="main-title detail">
						<div class="detail-left">
						<button type="button" class="btn btn-outline-light" id="popupBtn" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						</div>
						<div class="col-auto">
							<span style="width:500px; font-weight:bold;" class="text-warning param_name"></span>
						</div>
					</div>
<!-- /상세페이지 타이틀 -->
			<c:if test="${inputParam.popup_yn ne 'Y'}">
				<div class="contents" style="width:70%">
			</c:if>
			<c:if test="${inputParam.popup_yn eq 'Y'}">
				<div class="contents">
			</c:if>
<!-- 폼테이블 -->
					<div>
						<table class="table-border">
							<colgroup>
								<col width="80px">
								<col width="150px">
								<col width="80px">
								<col width="200px">
								<col width="80px">
								<col width="150px">
								<col width="80px">
								<col width="100px">
								<col width="80px">
								<col width="100px">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right essential-item">전표일자</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate rb" id="inout_dt" name="inout_dt" dateformat="yyyy-MM-dd" alt="전표일자" required="required" value="${inputParam.s_current_dt}">
										</div>
									</td>
									<th class="text-right">전표번호</th>
									<td>
										<input type="text" class="form-control" readonly="readonly">
									</td>
									<th class="text-right">업체명</th>
									<td colspan="2">
										<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name">
									</td>
									<th class="text-right">대표자</th>
									<td colspan="2">
										<input type="text" class="form-control" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">고객명</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0" readonly="readonly" id="cust_name" name="cust_name" required="required" alt="고객명">
											<input type="hidden" name="cust_no" id="cust_no">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goCustInfoClick();"><i class="material-iconssearch"></i></button>
										</div>
									</td>
									<th class="text-right">휴대폰</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0" readonly="readonly" id="cust_hp_no" name="cust_hp_no">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
										</div>
									</td>
									<th class="text-right">사업자번호</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-9">
												<input type="text" class="form-control" readonly="readonly" id="breg_no" name="breg_no" format="bregNo">
											</div>
											<div class="col-3"><button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:fnSearchBregSpec();">명세</button></div>
										</div>
									</td>
									<th class="text-right">전화</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="tel_no" name="tel_no" format="tel">
									</td>
									<th class="text-right">팩스</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="cust_fax_no" name="cust_fax_no" format="tel">
									</td>
								</tr>
								<tr>
									<th class="text-right">마케팅당당자</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="sale_mem_name" name="sale_mem_name">
										<input type="hidden" id="sale_mem_no" name="sale_mem_no">
									</td>
									<th class="text-right">처리자</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="reg_name" name="reg_name" value="${SecureUser.user_name}">
										<input type="hidden" id="reg_id" name="reg_id" value="${SecureUser.mem_no}">
									</td>
									<th rowspan="2" class="text-right">주소</th>
									<td colspan="5" rowspan="2">
										<div class="form-row inline-pd mb7">
											<div class="col-4">
												<input type="text" class="form-control" readonly="readonly" id="biz_post_no" name="biz_post_no">
											</div>
											<div class="col-8">
												<input type="text" class="form-control" readonly="readonly" id="biz_addr1" name="biz_addr1">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" readonly="readonly" id="biz_addr2" name="biz_addr2">
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">현미수</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control text-right" readonly="readonly" id="misu_amt" name="misu_amt" format="decimal" >
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
									<th class="text-right essential-item">전표구분</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-7">
												<select class="form-control sale-rb" id="inout_type_cd" name="inout_type_cd" required="required" alt="전표구분" onChange="fnChangeTxAmt();">
													<option value="">- 선택 -</option>
													<c:forEach var="item" items="${codeMap['INOUT_TYPE']}">
												 		<c:if test="${item.code_name eq '입금' || item.code_name eq '출금'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
													</c:forEach>
												</select>
											</div>
											<div class="col-5">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">계정구분</th>
									<td>
										<select class="form-control sale-rb" id="acc_type_cd" name="acc_type_cd" onchange="fnChangeDepositForm();" required="required" alt="계정구분">
											<option value="">- 선택 -</option>
											<c:forEach var="item" items="${codeMap['ACC_TYPE']}">
												 <c:if test="${item.code_v1 eq 'Y' && item.code_value ne '2'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
											</c:forEach>
										</select>
									</td>
									<th class="text-right">입금액</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="doc_amt" name="doc_amt" required="required" alt="입금액" format="minusNum" value="0" onChange="javascript:fnCalcAmt();">
												<input type="hidden" class="form-control text-right" id="inout_amt" name="inout_amt">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
									<th class="text-right">할인</th>
									<td colspan="2">
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="discount_amt" name="discount_amt" format="decimal" value="0" onChange="javascript:fnCalcAmt();">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
									<th class="text-right">합계금액</th>
									<td colspan="2">
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control text-right" readonly="readonly" id="total_amt" name="total_amt" format="decimal" value="0">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">최종메모</th>
									<td colspan="3">
										<input type="text" class="form-control" readonly="readonly" id="last_memo" name="last_memo">
									</td>
									<th class="text-right">비고</th>
									<td colspan="5">
										<input type="text" class="form-control" id="desc_text" name="desc_text">
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				<!-- 합계그룹 어음 -->
					<div class="row inline-pd mt10 dpn deposit_billin">
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">어음번호</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="bill_no" name="bill_no"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">만기일자</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="end_dt" name="end_dt" dateformat="yyyy-MM-dd" ></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">발행처</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="corp_cust_name" name="corp_cust_name"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
						</div>
						<div class="col" style="width: 20%;">
						</div>
					</div>
				<!-- /합계그룹 어음 -->
				<!-- 합계그룹 은행 -->
					<div class="row inline-pd mt10 dpn deposit_bank">
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">은행명</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="ibk_bank_name" name="ibk_bank_name"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">계좌번호</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="account_no" name="account_no"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum" id="inout_type_dt">입금일자</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="acct_txday" name="acct_txday" dateformat="yyyy-MM-dd" ></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum" id="inout_type_name">입금액</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="tx_amt" name="tx_amt" format="test" value="0"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum" id="inout_type_mem_name">입금자</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="jeokyo" name="jeokyo"></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				<!-- /합계그룹 은행 -->
				<!-- 합계그룹 카드 -->
					<div class="row inline-pd mt10 dpn deposit_card">
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">카드사</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="card_cmp_name" name="card_cmp_name"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">승인번호</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="approval_no" name="approval_no"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
						</div>
						<div class="col" style="width: 20%;">
						</div>
						<div class="col" style="width: 20%;">
						</div>
					</div>
					<!-- /합계그룹 카드 -->
					<!-- 합계그룹 대체 -->
					<div class="row inline-pd mt10 dpn deposit_replace">
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">대체계정</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="in_replace_acnt_name" name="in_replace_acnt_name"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right th-sum">대체고객명</th>
										<td class="text-right"><input type="text" class="form-control text-right" readonly="readonly" id="replace_cust_name" name="replace_cust_name"></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
						</div>
						<div class="col" style="width: 20%;">
						</div>
						<div class="col" style="width: 20%;">
						</div>
					</div>
					<!-- /합계그룹 대체 -->
<!-- /폼테이블 -->
					<div class="btn-group mt10" style="width:100%;">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
			<c:if test="${inputParam.popup_yn ne 'Y'}">
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
			</c:if>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
