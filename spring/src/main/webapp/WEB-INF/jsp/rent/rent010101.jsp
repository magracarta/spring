<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 렌탈신청현황 > 렌탈신규등록 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>
		var auiGrid;
		console.log("${inputParam.rental_machine_no}");
		
		var isProcessed = false;
		var isRfq = false; // 견적서 참조했는지 여부
		
		$(document).ready(function() {
			// AUIGrid 생성
			createauiGrid();
			if ("${latest_rental_doc_no}" != "") {
				alert("작성중인 상세페이지로 이동합니다.");
				var params = {
					rental_doc_no: "${latest_rental_doc_no}"
				};
				$M.goNextPage('/rent/rent0101p01', $M.toGetParam(params));
			} else {
				<c:if test="${not empty inputParam.cust_no}">
				fnSetCustInfo({cust_no: "${rent_req.cust_no}"});
				// getAttachPopup();
				</c:if>
				<c:if test="${not empty inputParam.s_cust_no}">
				fnSetCustInfo({cust_no: "${inputParam.s_cust_no}"});
				// getAttachPopup();
				</c:if>
			}

			// 계약자는 담당자 기본 셋팅
			$M.setValue("profit_mem_no_02", "${SecureUser.mem_no}")
			$M.setValue("profit_mem_name_02", "${SecureUser.kor_name}")


			<c:if test="${not empty selfAssignBean}">
			var selfAssignBean = ${selfAssignBean};
			if(selfAssignBean.c_rental_request_seq != ""){
				$M.setValue("c_rental_request_seq", selfAssignBean.c_rental_request_seq);
				$M.setValue("remark",selfAssignBean.consult_text);
			}
			</c:if>

			fnSaveBtnControl();
		});

		// 3-5차 업무접수 추가로인한 버튼 제어
		function fnSaveBtnControl() {
			// 신청참조, 매출처리, 예약, 저장 버튼 제어
			// 업무접수를 통하여 렌탈신청등록할 경우에만 노출. (최승희대리는 전부 노출)
			$("#_goRentalReferPopup").addClass('dpn');
			if ($M.getValue("s_self_assign_no") == '' && '${SecureUser.mem_no}' != 'MB00000133') {
				$("#_goSale").addClass('dpn');
				$("#_goResv").addClass('dpn');
				$("#_goSave").addClass('dpn');
			}
		}

		// 견적서참조
		function goReferEstimate(rfqNo) {
			var param = {
				rfq_no: rfqNo,
				disabled_yn: "Y"
			}
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=600, left=0, top=0";
			$M.goNextPage('/cust/cust0107p04', $M.toGetParam(param), {popupStatus: poppupOption});
		}

		function fnSetRfqRefer(row) {
			console.log(row);
			$M.goNextPageAjax("/rfq/refer/" + row.rfq_type_cd + "/" + row.rfq_no, "", {method: 'GET'},
					function (result) {
						if (result.success) {
							isRfq = true;
							$("#btnRefer").html("(견)" + result.rent.rfq_no);
							fnSetData(result);
						}
					}
			);
		}


		function fnSetData(result) {
			var rent = result.rent;
			var attach = result.attach;
			AUIGrid.clearGridData(auiGrid);
			var param = {
				cust_no : rent.cust_no,
				cust_name : rent.cust_name,
				hp_no : $M.phoneFormat(rent.hp_no),
				breg_name : rent.breg_name,
				breg_no : rent.breg_no,
				breg_seq : rent.breg_seq,
				breg_rep_name : rent.breg_rep_name,
				post_no : rent.post_no,
				addr1 : rent.addr1,
				addr2 : rent.addr2,
				rfq_no : rent.rfq_no,
				rental_st_dt : rent.rental_st_dt,
				rental_ed_dt : rent.rental_ed_dt,
				day_cnt : rent.day_cnt,
				discount_amt : rent.discount_amt,
			}
			$M.setValue(param);
			if (attach) {
				var reAttach = [];
				for (var i = 0; i < attach.length; ++i) {
					if (attach[i].rental_pos_status_cd != "0") {
						continue;
					}
					reAttach.push(attach[i]);
				}
				fnSetAttach(reAttach);
				if (reAttach.length != attach.length) {
					alert("이미 렌탈된 어태치먼트는 제외했습니다.");
				}
			}
			getMachinePrice();
			$("#rental_st_dt").attr("disabled", true);
			$("#rental_ed_dt").attr("disabled", true);
		};
		
		function createauiGrid() {
			var attachGridData = [];
			<c:if test="${not empty inputParam.parent_js_name}">
				attachGridData = opener.${inputParam.parent_js_name}();
			</c:if>
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showSelectionBorder : true,
				rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
					// 공지가 등록된 경우 체크 불가
					if (item.able_yn =='N') {
						return false;
					}

					return true;
				},
				independentAllCheckBox : true,
			};
			
			var columnLayout = [
				// {
				// 	dataField : "isActive",
				// 	headerText : "",
				// 	width : 30,
				// 	sortable : false,
				// 	headerRenderer : {
				// 		type : "CheckBoxHeaderRenderer",
				// 		// 헤더의 체크박스가 상호 의존적인 역할을 할지 여부(기본값:false)
				// 		// dependentMode 는 renderer 의 type 으로 CheckBoxEditRenderer 를 정의할 때만 활성화됨.
				// 		// true 설정했을 때 클릭하면 해당 열의 필드(데모 상은 isActive 필드)의 모든 데이터를 true, false 로 자동 바꿈
				// 		dependentMode : false,
				// 		position : "middle" // 기본값 "bottom"
				// 	},
				// 	renderer : {
				// 		type : "CheckBoxEditRenderer",
				// 		showLabel : false, // 참, 거짓 텍스트 출력여부( 기본값 false )
				// 		editable : true, // 체크박스 편집 활성화 여부(기본값 : false)
				// 		// 체크박스 disabled 함수
				// 		disabledFunction: function (rowIndex, columnIndex, value, isChecked, item, dataField) {
				// 			if (item.able_yn == "N")
				// 				return true; // true 반환하면 disabled 시킴
				// 			return false;
				// 		}
				// 	}
				// },
				{
					headerText : "어태치먼트명",
					dataField : "attach_name",
					width : "200",
					style : "aui-left"
				},
				{
					headerText : "총수량",
					dataField : "total_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "렌탈중",
					dataField : "rental_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "가용수량",
					dataField : "able_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "렌탈금액",
					dataField : "amt",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					visible : false,
				},
				{
					headerText : "수량", 
					dataField : "qty",
					visible : false,
				},
				{
					headerText : "매입처",
					dataField : "client_name",
					visible : false,
				},
				{
					headerText : "일련번호",
					dataField : "product_no",
					visible : false,
				},
				{
					headerText : "렌탈일수",
					dataField : "day_cnt",
					visible : false,
				},
				// {
				// 	headerText : "삭제",
				// 	dataField : "h",
				// 	renderer : {
				// 		type : "ButtonRenderer",
				// 		onClick : function(event) {
				// 			AUIGrid.removeRow(event.pid, event.rowIndex);
				// 			AUIGrid.removeSoftRows(auiGrid);
				// 			getAttachPrice();
				// 		}
				// 	},
				// 	labelFunction : function(rowIndex, columnIndex, value,
				// 			headerText, item) {
				// 		return '삭제'
				// 	}
				// },
				{
					dataField : "rental_attach_no",
					visible : false
				},
				{
					dataField : "cost_yn",
					visible : false
				},
				{
					dataField : "base_yn",
					visible : false
				},
				{
					dataField : "able_yn",
					visible : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
<%--			<c:if test="${empty inputParam.parent_js_name}">--%>
			AUIGrid.setGridData(auiGrid, ${attach});
<%--			</c:if>--%>
			<c:if test="${not empty inputParam.parent_js_name}">
			var checkList = [];

			var auiGridData = AUIGrid.getGridData(auiGrid);
			for (var i = 0; i < attachGridData.length; ++i) {
				for(var j = 0; j < auiGridData.length; j++) {
					if(attachGridData[i].part_no == auiGridData[j].part_no && auiGridData[j].able_yn != "N") {
						checkList.push(attachGridData[i].part_no);
						break;
					}
				}
			}
			AUIGrid.setCheckedRowsByValue(auiGrid, "part_no", checkList);
			getAttachPrice();
			</c:if>

			AUIGrid.bind(auiGrid, "rowAllChkClick", function( event ) {
				if(event.checked) {
					var uniqueValues = AUIGrid.getGridData(auiGrid);
					var list = [];
					for (var i = 0; i < uniqueValues.length; ++i) {
						if (uniqueValues[i].able_yn != "N") {
							list.push(uniqueValues[i].part_no);
						}
					}
					AUIGrid.setCheckedRowsByValue(event.pid, "part_no", list);
				} else {
					AUIGrid.setCheckedRowsByValue(event.pid, "part_no", []);
				}
			});

			AUIGrid.bind(auiGrid, "rowCheckClick", function( event ) {
				getAttachPrice();
			});
		}
		
		function goProcess(c) {
			// IE fix
			var control = c;
			if (isProcessed == true) {
				alert("이미 처리한 자료입니다.");
				fnClose();
				return false;
			}
			if(control == "MS") {
				$M.setValue("day_1_price", '${rent.day_1_price}');
				$M.setValue("day_7_price", $M.toNum('${rent.day_1_price}') * 7);
				$M.setValue("day_30_price", $M.toNum('${rent.day_1_price}') * 30);
				$M.setValue("day_365_price", $M.toNum('${rent.day_1_price}') * 365);
			}
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}

			if ($M.getValue("rental_delivery_cd") != "01" && $M.getValue("rental_delivery_cd") != "") {
				if($M.validation(frm, {field : ["delivery_post_no"]}) == false) {
					return;
				};
			} 
			if($M.checkRangeByFieldName("rental_st_dt", "rental_ed_dt", true) == false) {				
				return;
			}; 
			$M.getValue("contract_make_yn_check") == "" ? $M.setValue("contract_make_yn", "N") : $M.setValue("contract_make_yn", "Y");
	    	$M.getValue("id_copy_yn_check") == "" ? $M.setValue("id_copy_yn", "N") : $M.setValue("id_copy_yn", "Y");
			frm = $M.toValueForm(frm);
			// var concatCols = [];
			// var concatList = [];
			// var gridIds = [auiGrid];
			// for (var i = 0; i < gridIds.length; ++i) {
			// 	concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			// 	concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			// }
			//
			// var gridForm = fnGridDataToForm(concatCols, concatList);
			var gridForm = fnCheckedGridDataToForm(auiGrid);
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);
			var msg;

			if(control == "MS") {
				$M.goNextPageAjax(this_page, gridForm, {method : 'POST'},
						function(result) {
							if(result.success) {
								isProcessed = true;
								var param = {
									rental_doc_no : result.rental_doc_no
								}
								$M.goNextPage('/rent/rent0101p01', $M.toGetParam(param));
								fnClose();
							}
						}
				);
			} else {
				if (control == "S") {
					msg = "저장하시겠습니까?";
				}else if (control == "P") {
					msg = "저장후, 인쇠하시겠습니까?";
				} else if (control == "R") {
					msg = "예약하시겠습니까?";
				} else if (control == "CR") {
					msg = "예약취소하시겠습니까?";
				} else if (control == "D") {
					msg = "삭제하시겠습니까?";
				} else if (control == "SALE") {
					msg = "매출처리하시겠습니까?";

					if($M.getValue("paper_file_seq") == '' || $M.getValue("paper_file_seq") == '0') {
						alert('전자서명이 완료되거나 종이계약서 업로드 시 매출처리가 가능합니다.');
						return false;
					}
				}
				if ($M.getValue("cust_grade_hand_cd_str").indexOf("04") != -1) {
					msg = "그레이장비 보유 고객입니다. " + msg;
				}
				$M.goNextPageAjaxMsg(msg, this_page, gridForm, {method : 'POST'},
						function(result) {
							if(result.success) {
								isProcessed = true;
								var param = {
									rental_doc_no : result.rental_doc_no
								}
								if (control == "SALE") {
									setTimeout(function() {
										openInoutProcPanel("fnSetSaleResult", $M.toGetParam(param));
										if ( control == 'P'){
											goSavePrint(result.rental_doc_no);
										}else $M.goNextPage('/rent/rent0101p01', $M.toGetParam(param));
									}, 1000);
								} else {
									alert("저장이 완료되었습니다.");
									if ( control == 'P'){
										goSavePrint(result.rental_doc_no);
									}else $M.goNextPage('/rent/rent0101p01', $M.toGetParam(param));
								}
								if(window.opener != null){
									window.opener.opener.location.reload();
									window.opener.close();
								}
							}
						}
					);
			}
		}


		
		// 매출처리 완료 후
		function fnSetSaleResult() {
			fnClose();
		}
		
		// 매출처리
		function goSale() {
			$M.setValue("mode", "S");
			goProcess("SALE");
		} 
		
		// 저장
		function goSave() {
			$M.setValue("mode", "S");
			goProcess("S");
		}

		// 예약
		function goResv() {
			$M.setValue("mode", "R");
			goProcess("R");
		}
		
		// 예약취소
		function goCancelResv() {
			$M.setValue("mode", "CR");
			goProcess("CR");
		}
		
		// 예약확정
		function goConfirmResv() {
			$M.setValue("mode", "RC");
			goProcess("RC");
		}
		
	    function fnSetArrival1Addr(row) {
	        var param = {
		        delivery_post_no: row.zipNo,
		        delivery_addr1: row.roadAddr,
		        delivery_addr2: row.addrDetail
	        };
	        $M.setValue(param);
	    }
		
	    function fnChangeDeliveryCd() {
	    	$(".two_way_yn").hide();
			var cd = $M.getValue("rental_delivery_cd");
			if (cd == "01") {
				$(".dc *").attr("disabled", true);
				$(".r1s").removeClass("rs");
			} else {
				$(".dc *").attr("disabled", false);
				$(".r1s").addClass("rs");
			}
			if (cd == "03" || cd == "04") {
				$("#transport_amt").prop('disabled', false);
				if (cd == "04") {
					alert("운송사 착불을 유도하고 불가피 할 경우에만 사용 하시고 수주매출로 따로 운송비처리하는 것을 금지합니다.");
				}
				if (cd == "03") {
					$(".two_way_yn").show();
				}
			} else {
				$M.setValue("transport_amt", "0");
				$("#transport_amt").prop('disabled', true);
			}
			fnCalc();
		}
		
		//어태치먼트추가
	    function goAttachPopup() {
			var rows = AUIGrid.getGridData(auiGrid);
			// 2020-08-10 회의
			// 이동, 재렌탈는 소유센터의  어태치만 조회
			// 고객렌탈일떄는 관리센터의 어태치만 조회
	     	var params = {
	     		mng_org_code : "${rent.mng_org_code}",
	     		rental_machine_no : "${rent.rental_machine_no}",
	     		// not_rental_attach_no : $M.getArrStr(rows, {key : 'rental_attach_no'}),
				apply_yn : "N",
		    };
	     	openRentalAttachPanel("fnSetAttach", $M.toGetParam(params));
	    }

		// 어테치 먼트 조회 - 2022-11-11 정비견적서 상세 - 렌탈신청등록
	    <%--function getAttachPopup() {--%>
		<%--	$M.goNextPageAjax("/cust/cust0107p04/${rent_req.rfq_no}/attach", "", {method : 'GET'},--%>
		<%--			function(result) {--%>
		<%--				if(result.success) {--%>
		<%--					fnSetAttach(JSON.parse(result.attach));--%>
		<%--				}--%>
		<%--			}--%>
		<%--	);--%>
	    <%--}--%>
		
		function fnSetAttach(row) {
			var item = new Object();
			if(row != null) {
				for(i=0; i<row.length; i++) {
					item.part_name = row[i].part_name;
					item.part_no = row[i].part_no;
					item.qty = 1;
					item.product_no = row[i].product_no;
					item.client_name = row[i].client_name;
					item.rental_attach_no = row[i].rental_attach_no;
					item.attach_name = row[i].attach_name;
					item.day_cnt = $M.getValue("day_cnt");
					item.amt = 0;
					item.cost_yn = row[i].cost_yn;
					item.base_yn = row[i].base_yn;
					item.total_cnt = row[i].total_cnt;
					item.rental_cnt = row[i].rental_cnt;
					item.able_cnt = row[i].able_cnt;
					item.able_yn = row[i].able_yn;
					AUIGrid.addRow(auiGrid, item, 'last');
				}
				getAttachPrice();
			}
			AUIGrid.resize(auiGrid);
		}
		
		function fnCalc() {
		   var machine_rental_price = $M.toNum($M.getValue("machine_rental_price"));
		   var sumAttachAmt = 0;
		   var gridData = AUIGrid.getCheckedRowItemsAll(auiGrid);
		   for (var i = 0; i < gridData.length; ++i) {
			   sumAttachAmt+=$M.toNum(gridData[i].amt * gridData[i].qty);
		   }
		   var attach_rental_price = sumAttachAmt; // $M.toNum($M.getValue("attach_rental_price"));
		   $M.setValue("attach_rental_price", attach_rental_price);
		   var total_rental_amt = machine_rental_price + attach_rental_price;
		   var discount_amt = $M.toNum($M.getValue("discount_amt"));
		   var total_amt = total_rental_amt - discount_amt;
		   $M.setValue("total_rental_amt", total_rental_amt);
		   var transport_amt = $M.toNum($M.getValue("transport_amt"));
		   if ($M.getValue("rental_delivery_cd") == "03" || $M.getValue("rental_delivery_cd") == "04") {
			   total_amt += transport_amt;
		   }
			var tempTotalAmt = total_amt;
			var mch_deposit_amt = $M.toNum($M.getValue("mch_deposit_amt"));
			total_amt = total_amt + mch_deposit_amt;
			$M.setValue("rental_amt", total_amt);
			// $M.setValue("vat_rental_amt", Math.floor(total_amt*1.1));
		   $M.setValue("vat_rental_amt", Math.floor(tempTotalAmt*1.1) + mch_deposit_amt);
	    }
	
	    function fnClose() {
			if(window.opener != null){
				window.opener.location.reload();
			}
	    	window.close();
	    }
	    
	    // 고객조회 결과
	    // function fnSetCustInfo(row) {
		// 	var param = {
		// 			hp_no : $M.phoneFormat(row.real_hp_no),
		// 			cust_name : row.real_cust_name,
		// 			cust_no : row.cust_no,
		// 			addr1 : row.addr1,
		// 			addr2 : row.addr2,
		// 			breg_name : row.breg_name,
		// 			breg_no : row.breg_no
		// 	}
		// 	$M.setValue(param);
		//
		// 	goSearchPrivacyAgree();
	    // }

		// 고객조회 결과 - 견적서 관리에서 등록할 경우 정보를 불러옴
		function fnSetCustInfo(row) {
			$M.goNextPageAjax("/rent/custInfo/"+row.cust_no, "", {method : 'GET'},
					function(result) {
						if(result.success) {
							var custGradeHandCdStr = result.cust_grade_hand_cd_str;
							$M.setValue("cust_grade_hand_cd_str", custGradeHandCdStr);
							if (custGradeHandCdStr.indexOf("03") != -1) {
								alert("거래금지 고객입니다. 확인후 진행해주세요.");
								return false;
							}
							if (custGradeHandCdStr.indexOf("04") != -1) {
								alert("그레이장비 보유 고객입니다. 렌탈신청 전에 확인 바랍니다.");
							}

							var param = {
								hp_no : $M.phoneFormat(result.hp_no),
								cust_no : result.cust_no,
								cust_name : result.cust_name,
								addr1 : result.addr1,
								addr2 : result.addr2,
								breg_name : result.breg_name,
								breg_no : result.breg_no,
								email : result.email,
								breg_type_name : result.breg_type_name,
								machine_has_yn : result.machine_has_yn,
								total_rental_cnt : result.total_rental_cnt,
								year_rental_cnt : result.year_rental_cnt,
							}
							$M.setValue(param);
							$('#breg_type_name').html(result.breg_type_name);
							goSearchPrivacyAgree();
							fnRentalDayCheck();
						}
					}
			);
		}
	    
	    function fnSetDayCnt() {
	    	if ($M.getValue("rental_st_dt") == "" || $M.getValue("rental_ed_dt") == "") {
	    		$M.setValue("day_cnt", 0);
	    	} else {
	    		if ($M.toNum($M.getValue("rental_st_dt")) > $M.toNum($M.getValue("rental_ed_dt"))) {
	    			$M.setValue("rental_ed_dt", $M.getValue("rental_st_dt"));
	        		alert("렌탈 종료가 렌탈 시작 이전 입니다.");
	        		$M.setValue("day_cnt", 1);
	    		} else {
	    			var cnt = $M.getDiff($M.getValue("rental_ed_dt"), $M.getValue("rental_st_dt"));
	    			$M.setValue("day_cnt", cnt);
	    		}
	    		getMachinePrice();
	    	}
			fnRentalDayCheck();

	    	AUIGrid.resize(auiGrid);
	    }

		function fnRentalDayCheck() {
			var dayCnt = $M.toNum($M.getValue("day_cnt"));
			if(dayCnt < 8) {
				$M.setValue("rental_day_check", "A");
			} else if(dayCnt >= 8 && dayCnt < 32) {
				$M.setValue("rental_day_check", "B");
			} else {
				$M.setValue("rental_day_check", "C");
			}
		}
	    
	    function getMachinePrice() {
	    	if ($M.getValue("day_cnt") == "" || $M.getValue("day_cnt") == "0") {
	    		return false;
	    	}
	    	var param = {
	    		rental_machine_no : "${rent.rental_machine_no}",
	    		day_cnt : $M.getValue("day_cnt")
	    	}
			$M.goNextPageAjax(this_page+"/calc/machine", $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			$M.setValue("machine_rental_price", result.price);
		    			getAttachPrice();
					}
				}
			);
	   }
	    
	   function getAttachPrice() {
	    	var rows = AUIGrid.getGridData(auiGrid);
	    	var dayCnt = $M.toNum($M.getValue("day_cnt"));
	    	if (rows.length < 1 || dayCnt == 0) {
	    		fnCalc();
	    		return false;
	    	}
	    	var dayArr = [];
	    	for (var i = 0; i < rows.length; ++i) {
	    		dayArr.push(dayCnt);
	    		AUIGrid.updateRow(auiGrid, {"day_cnt" : dayCnt },i);
	    	}
	    	var param = {
	    		rental_attach_no_str : $M.getArrStr(rows, {sep : "#", key : "rental_attach_no", isEmpty : true}),
	    		day_cnt_str : $M.getArrStr(dayArr),
	    		base_yn_str : $M.getArrStr(rows, {sep : "#", key : "base_yn", isEmpty : true}),
	    		cost_yn_str : $M.getArrStr(rows, {sep : "#", key : "cost_yn", isEmpty : true}),
	    	}
	    	console.log(param);
			$M.goNextPageAjax(this_page+"/calc/attach", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			console.log(result);
			    			var total = 0;
			    			for (var i = 0; i < result.attachPrice.length; ++i) {
			    				total+=result.attachPrice[i];
			    				var obj = {
			    					amt :  result.attachPrice[i]
			    				}
			    				AUIGrid.updateRow(auiGrid, obj, i);
			    			}
			    			fnCalc();
						}
					}
				);
	    }
	   
		 // 개인정보동의 팝업
		function goSearchPrivacyAgree() {
			var param = {
				cust_no: $M.getValue("cust_no")
			}
			$M.goNextPageAjax("/comp/comp0306/search", $M.toGetParam(param), {method: 'get'},
					function (result) {
						if (result.success) {
							var custInfo = result.custInfo;
							if (custInfo.personal_yn != "Y") {
								if (confirm("개인정보 동의사항을 확인하세요") == true) {
									openPrivacyAgreePanel('fnSetPrivacy', $M.toGetParam(param));
								}
							}
						}
					}
			);
		}

		function goDocPrint() {
			openReportPanel('cust/cust0107p04_01.crf','rfq_no=${rent_req.rfq_no}&cust_no=${rent_req.cust_no}');
		}

		function goSavePrint(rental_doc_no){
			var params = {
				"rental_doc_no" : rental_doc_no,
				"rental_machine_no" : '${inputParam.rental_machine_no}'
			}

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=720, height=250, left=0, top=0";
			$M.goNextPage('/comp/comp1002', $M.toGetParam(params), {popupStatus : popupOption});

			// [재호] [3차-Q&A 15591] 렌탈 신청 상세 수정 추가
			// - 고객명, 회사명 선택 팝업 추가
			// openReportPanel('rent/rent0101p01_01.crf','rental_doc_no=' + $M.getValue("rental_doc_no"));
		}
		
		// 개인정보 동의 세팅
		function fnSetPrivacy(data) {
		}
		
		// 수익배분
		function fnSetProfit01(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_01", row.mem_no);
			$M.setValue("profit_mem_name_01", row.mem_name);
		}
		
		function fnSetProfit02(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_02", row.mem_no);
			$M.setValue("profit_mem_name_02", row.mem_name);
		}
		
		function fnSetProfit03(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_03", row.mem_no);
			$M.setValue("profit_mem_name_03", row.mem_name);
		}
		
		function goSearchMemberPanel(fn) {
			var param = {
				"agency_yn" : "N"
			}									
			openMemberOrgPanel(fn, "N" , $M.toGetParam(param));
		}
    
		// 업무DB 연결 함수 21-08-06이강원
     	function openWorkDB(){
     		openWorkDBPanel('',${rent.machine_plant_seq});
     	}

		// [재호] [3차-Q&A 15591] 장비대장 추가
		// 장비 대장 상세
		function goMachineDetail() {
			// 보낼 데이터
			var params = {
				"s_machine_seq" : '${rent.machine_seq}'
			};
			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
			$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		// 렌탈이력
		function goRentalHisPopup() {
			var params = {
				machine_name : "${rent.machine_name}",
				body_no : "${rent.body_no}",
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p04', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		//이동이력
		function goMoveHisPopup() {
			var params = {
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p05', $M.toGetParam(params), {popupStatus : popupOption});

		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		//수리이력
		function goAsHisPop() {
			var params = {
				s_machine_seq : "${rent.machine_seq}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		// 렌탈장비대장
		function goRentalMachineDetail() {
			var params = {
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=520, left=0, top=0";
			$M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 모두싸인 요청 (저장 후 진행)
		function sendModusignPanel() {
			if($M.getValue("cust_no") == "") {
				alert("고객선택 후 진행해주세요.");
				return;
			}

			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}

			var params = {
				"cust_name" : $M.getValue("cust_name"),
				"hp_no" : $M.getValue("hp_no"),
				"email" : $M.getValue("email"),
				"breg_name" : $M.getValue("breg_name"),
				"confirm_msg" : "발송 시 문서내용이 저장 후 발송처리됩니다.\n발송하시겠습니까?",
			}

			openSendModusignPanel('sendModusignAfterSave', $M.toGetParam(params));
		}

		// 모두싸인 대면요청 (저장 후 진행)
		function sendContactModusignPanel() {
			if($M.getValue("cust_no") == "") {
				alert("고객선택 후 진행해주세요.");
				return;
			}

			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}

			var params = {
				"cust_name" : $M.getValue("cust_name"),
				"hp_no" : $M.getValue("hp_no"),
				"email" : $M.getValue("email"),
				"breg_name" : $M.getValue("breg_name"),
				"confirm_msg" : "고객앱 전송 시 문서내용이 저장 후 전송처리됩니다.\n전송하시겠습니까?",
			}

			openSendContactModusignPanel('sendModusignAfterSave', $M.toGetParam(params));
		}

		function sendModusignAfterSave(data) {
			$M.setValue("cust_breg_name", data.cust_name);
			$M.setValue("modusign_send_cd", data.modusign_send_cd);
			$M.setValue("send_hp_no", data.modusign_send_value);
			$M.setValue("send_email", data.modusign_send_value);
			$M.setValue("mode", "MS");
			goProcess("MS");
		}

		// 첨부파일 출력
		function fnPrintFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item paper_file" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="paper_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile()"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.paper_file_div').append(str);
		}

		// 첨부파일 버튼 클릭
		function fnAddFile(){
			if($M.getValue("paper_file_seq") != "0" && $M.getValue("paper_file_seq") != "") {
				alert("파일은 1개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=RENT&file_type=img&max_size=10240');
		}

		function setFileInfo(result) {
			fnPrintFile(result.file_seq, result.file_name);
			$('#paperFileBtn').remove();
		}

		// 첨부파일 삭제
		function fnRemoveFile() {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".paper_file").remove();
				$(".paper_file_td").append('<button type="button" class="btn btn-primary-gra" id="paperFileBtn" onclick="javascript:fnAddFile()" >파일찾기</button>');
			} else {
				return false;
			}
		}

		// 신청참조
		function goRentalReferPopup() {
			var param = {
				machine_plant_seq : '${rent.machine_plant_seq}',
				org_code : '${rent.mng_org_code}',
				extend_yn : 'N',
			};

			openRentalRequestReferPopup('setRentalRequestRefer', $M.toGetParam(param));
		}

		function setRentalRequestRefer(data) {
			$M.setValue("rental_st_dt", data.rental_st_dt);
			$M.setValue("rental_ed_dt", data.rental_ed_dt);
			$M.setValue("c_rental_request_seq", data.c_rental_request_seq);
			fnSetDayCnt();

			$('#_goSearchCust').attr('disabled', true);

			fnSetCustInfo(data);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="mode">
<input type="hidden" name="rfq_no">
<input type="hidden" name="contract_make_yn">
<input type="hidden" name="id_copy_yn">
<input type="hidden" id="cust_grade_hand_cd_str" name="cust_grade_hand_cd_str">
<input type="hidden" name="machine_type_name" value="${rent.machine_type_name}">
<input type="hidden" name="machine_name" value="${rent.machine_name}">
<input type="hidden" name="rental_machine_no" value="${rent.rental_machine_no}">
<input type="hidden" name="s_self_assign_no" value="${inputParam.s_self_assign_no}">
<div class="layout-box" style="min-width: 1400px;">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box" style="border:none;">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						<!-- 인쇠하기 버튼 -->
						<c:if test="${not empty rent_req}">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
								<jsp:param name="pos" value="TOP_R"/>
							</jsp:include>
						</c:if>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
					<div class="row">
						<div class="col-6">
<!-- 장비정보 -->
							<div class="title-wrap approval-left">
								<h4>장비정보</h4>
								<div class="right">
									<span class="condition-item">상태 :
										<c:choose>
											<c:when test="${empty rent.rental_status_name }">작성중</c:when>
											<c:otherwise>
												${rent.rental_status_name }
											</c:otherwise>
										</c:choose> 
									</span>
								</div>
							</div>			
							<table class="table-border mt5">
								<colgroup>
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">메이커</th>
										<td colspan="3">
											<input type="text" class="form-control width120px" readonly="readonly" value="${rent.maker_name}">
										</td>
										<th class="text-right">모델</th>
										<td colspan="3">
											<div class="form-row inline-pd pr">
												<div class="col-auto">
													<input type="text" class="form-control width120px" readonly="readonly" value="${rent.machine_name}" style="display: inline-block;">
												</div>
												<div class="col-auto">
							                        <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
									            </div>
											</div>
											<!-- 견적서 참조 주석 -->
											<!-- <button type="button" class="btn btn-primary-gra spacing-sm" style="display: inline-block;" onclick="javascript:goReferEstimate();" id="btnRefer">견적서참조</button> -->
										</td>
									</tr>
									<tr>
										<th class="text-right">연식</th>
										<td colspan="3">
											<input type="text" class="form-control width60px" readonly="readonly" value="${fn:substring(rent.made_dt,0,4)}">
										</td>
										<th class="text-right">가동시간</th>
										<td colspan="3">
											<div class="form-row inline-pd widthfix">
												<div class="col width60px">
													<input type="text" class="form-control" readonly="readonly" value="${rent.op_hour }" format="decimal" id="op_hour" name="op_hour">
												</div>
												<div class="col width22px">hr</div>
											</div>
										</td>	
									</tr>
									<tr>
										<th class="text-right">차대번호</th>
										<td colspan="3">
											<div style="display: flex">
												<input type="text" class="form-control width180px" style="margin-right: 10px" name="body_no" readonly="readonly" value="${rent.body_no }">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
											</div>
										</td>
										<th class="text-right">번호판번호</th>
										<td colspan="3">
											<input type="text" class="form-control width120px" readonly="readonly" value="${rent.mreg_no }">
										</td>
									</tr>
									<tr>
										<th class="text-right">GPS</th>
										<td colspan="3">
											<c:choose>
												<c:when test="${not empty rent.sar }">
													<span class="underline" onclick="javascript:window.open('https://terra.smartassist.yanmar.com/machine-operation/map')">SA-R</span>
												</c:when>
												<c:otherwise>
													<input type="hidden" id="gps_seq" name="gps_seq" value="${rent.gps_seq}" >
													<div class="form-row inline-pd widthfix">
														<div class="col width33px text-right">
															종류
														</div>
														<div class="col width80px">
															<select class="form-control" id="gps_type_cd" name="gps_type_cd" disabled="disabled">
																<option value="">- 선택 -</option>
																<c:forEach items="${codeMap['GPS_TYPE']}" var="codeitem">
																	<option value="${codeitem.code_value}" ${rent.gps_type_cd eq codeitem.code_value ? 'selected="selected"' : ''}>${codeitem.code_name}</option>
																</c:forEach>
															</select>
														</div>
														<div class="col width55px text-right">
															개통번호
														</div>
														<div class="col width100px">
															<input type="text" class="form-control underline" readonly="readonly" id="gps_no" name="gps_no" value="${rent.gps_no}" onclick="javascript:window.open('http://s1.u-vis.com')">
														</div>
													</div>
												</c:otherwise>
											</c:choose>
										</td>
										<th class="text-right">관리센터</th>
										<td>
											<input type="text" class="form-control width120px" readonly="readonly" value="${rent.mng_org_name }">
										</td>
										<th class="text-right">소유센터</th>
										<td>
											<input type="text" class="form-control width120px" readonly="readonly" value="${rent.own_org_name }">
										</td>
									</tr>										
								</tbody>
							</table>			
<!-- /장비정보 -->	
						</div>
						<div class="col-6">
<!-- 고객정보 -->
							<div class="title-wrap">
								<h4>고객정보</h4>
								<div class="right mt-5">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
									<!-- <button type="button" class="btn btn-md btn-rounded btn-outline-primary"  onclick="javascript:goPrint();"><i class="material-iconsprint text-primary"></i> 임대차계약서인쇄</button> -->
								</div>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="120px">
									<col width="100px">
									<col width="120px">
									<col width="100px">
									<col width="120px">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right rs">고객명/휴대전화</th>
										<td colspan="2">
											<div class="row">
												<div class="col-6">
													<div class="input-group">
															<input type="text" class="form-control border-right-0" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명" value="${rent_req.cust_name }">
															<input type="hidden" id="cust_no" name="cust_no" value="${rent_req.cust_no }">
															<button type="button" class="btn btn-icon btn-primary-gra"  onclick="javascript:openSearchCustPanel('fnSetCustInfo');" id="_goSearchCust" name="_goSearchCust"><i class="material-iconssearch" ></i></button>
													</div>
												</div>
												<div class="col-6">
													<input type="text" class="form-control width120px" readonly="readonly" id="hp_no" name="hp_no" value="${rent_req.hp_no }" format="tel">
												</div>
											</div>
										</td>
										<th class="text-right">업체명/사업자번호</th>
										<td colspan="2">
											<div class="row">
												<div class="col-6">
													<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name" value="${rent_req.breg_name }">
												</div>
												<div class="col-6">
													<input type="text" class="form-control" readonly="readonly" id="breg_no" name="breg_no" value="${rent_req.breg_no }" format="bregno">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">주소</th>
										<td colspan="5">
											<div class="row">
												<div class="col-5">
													<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1" value="${rent_req.addr1 }">
												</div>
												<div class="col-5">
													<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2" value="${rent_req.addr2 }">
												</div>
												<div class="col-2">
													<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">사업자등록구분</th>
										<td>
											<div id="breg_type_name">
											</div>
										</td>
										<th class="text-right">장비보유여부</th>
										<td>
											<div class="row" style="margin-left:1px;">
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" id="machine_has_yn_y" name="machine_has_yn" value="Y" <c:if test="${rent_req.machine_has_yn == 'Y'}">checked="checked"</c:if> disabled>
													<label class="form-check-label" for="machine_has_yn_y">보유</label>
												</div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" id="machine_has_yn_n" name="machine_has_yn" value="N" <c:if test="${rent_req.machine_has_yn == 'N'}">checked="checked"</c:if> disabled>
													<label class="form-check-label" for="machine_has_yn_n">미보유</label>
												</div>
											</div>
										</td>
										<th class="text-right" rowspan="2">계약일수</th>
										<td rowspan="2">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="day_cnt_under_7" name="rental_day_check" value="A" <c:if test="${rent_req.rental_day_check == 'A'}">checked="checked"</c:if> disabled>
												<label class="form-check-label" for="day_cnt_under_7">7일 이하</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="day_cnt_under_31" name="rental_day_check" value="B" <c:if test="${rent_req.rental_day_check == 'B'}">checked="checked"</c:if> disabled>
												<label class="form-check-label" for="day_cnt_under_31">8~31일</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="day_cnt_over_31" name="rental_day_check" value="C" <c:if test="${rent_req.rental_day_check == 'C'}">checked="checked"</c:if> disabled>
												<label class="form-check-label" for="day_cnt_over_31">32일 이상</label>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">당년 렌탈이력</th>
										<td>
											<div class="row">
												<div class="col-6">
													<input type="text" class="form-control" readonly="readonly" id="year_rental_cnt" name="year_rental_cnt" value="${rent_req.year_rental_cnt}">
												</div>
												회
											</div>
										</td>
										<th class="text-right">총 렌탈이력</th>
										<td>
											<div class="row">
												<div class="col-6">
													<input type="text" class="form-control" readonly="readonly" id="total_rental_cnt" name="total_rental_cnt" value="${rent_req.total_rental_cnt}">
												</div>
												회
											</div>
										</td>
									</tr>
								</tbody>
							</table>
							<div class="text-warning" style="text-align: right;">※ 대형법인의 개념 : 대기업 / 상장사 / 중견기업 / 담당자 판단하에 업체 규모가 크다고 판단하는 경우 선택</div>
<!-- /고객정보 -->	
						</div>
					</div>
					<div class="row mt10">
						<div class="col-6">
<!-- 렌탈정보 -->
							<div class="title-wrap approval-left">
								<div class="left">
									<h4>렌탈정보</h4>
									<div class="right text-warning ml5">
										1일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_1_price}" />&nbsp;&nbsp;
										7일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_7_price}" />&nbsp;&nbsp;
										15일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_15_price}" />&nbsp;&nbsp;
										30일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_30_price}" />
									</div>
								</div>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">관리번호</th>
										<td colspan="3">
											<div class="form-row inline-pd widthfix">
												<div class="col width110px">
													<input type="text" class="form-control" readonly="readonly" value="${fn:split(rent.rental_doc_no,'-')[0]}">
												</div>
												<%-- <div class="col width16px text-center">-</div>
												<div class="col width50px">
													<input type="text" class="form-control" readonly="readonly" value="${fn:split(rent.rental_doc_no,'-')[1]}">
												</div> --%>
											</div>
										</td>	
										<th class="text-right">담당자</th>
										<td colspan="3">
											<input type="text" class="form-control width100px" readonly="readonly" value="${SecureUser.kor_name }">
											<input type="hidden" id="receipt_mem_no" name="receipt_mem_no" value="${SecureUser.mem_no }">
										</td>
									</tr>
									<tr>
										<th class="text-right rs">렌탈기간</th>
										<td colspan="7">
											<div class="form-row inline-pd widthfix">
												<div class="col width110px">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate rb" id="rental_st_dt" name="rental_st_dt" dateFormat="yyyy-MM-dd" alt="렌탈 시작일" value="${rent.rental_st_dt ? rent.rental_st_dt : rent_req.rental_st_dt }" onchange="fnSetDayCnt()" required="required">
													</div>
												</div>
												<div class="col width16px text-center">~</div>
												<div class="col width120px">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate rb" id="rental_ed_dt" name="rental_ed_dt" dateFormat="yyyy-MM-dd" alt="렌탈 종료일" value="${rent.rental_ed_dt ? rent.rental_ed_dt : rent_req.rental_ed_dt }" onchange="fnSetDayCnt()" required="required">
													</div>
												</div>
												<div class="col width50px text-right">
													<input type="text" class="form-control" readonly="readonly" id="day_cnt" name="day_cnt" value="${rent.day_cnt ? rent.day_cnt : rent_req.day_cnt}" format="decimal">
												</div>
												<div class="col width16px">
													일
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right rs">인도방법</th>
										<td colspan="3">
											<select class="form-control width130px rb inline" id="rental_delivery_cd" name="rental_delivery_cd" required="required" alt="인도방법" onchange="javascript:fnChangeDeliveryCd()">
												<option value="">- 선택 -</option>
												<c:forEach items="${codeMap['RENTAL_DELIVERY']}" var="item">
													<option value="${item.code_value}" <c:if test="${item.code_value eq rent_req.rental_delivery_cd}">selected="selected"</c:if>>${item.code_name}</option>
												</c:forEach>
											</select>
											<div style="display: inline-block; vertical-align: middle; margin-left: 5px;">
												<div class="two_way_yn" style="display: none;">
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" id="two_way_yn_n" name="two_way_yn" value="N" <c:if test="${rent.two_way_yn == 'N' || rent_req.two_way_yn == 'N'}">checked="checked"</c:if>>
														<label class="form-check-label" for="two_way_yn_n">편도</label>
													</div>
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" id="two_way_yn_y" name="two_way_yn" value="Y" <c:if test="${rent.two_way_yn == 'Y' || rent_req.two_way_yn == 'Y'}">checked="checked"</c:if>>
														<label class="form-check-label" for="two_way_yn_y">왕복</label>
													</div>
												</div>
											</div>
										</td>
										<th class="text-right">서류</th>
										<td colspan="3">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="checkbox" name="contract_make_yn_check" id="contract_make_yn_check" value="Y" <c:if test="${rent.contract_make_yn == 'Y' || rent_req.contract_make_yn == 'Y'}">checked="checked"</c:if>>
												<label class="form-check-label" for="contract_make_yn_check">계약서작성</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="checkbox" name="id_copy_yn_check" id="id_copy_yn_check" value="Y" <c:if test="${rent.id_copy_yn == 'Y' || rent_req.id_copy_yn == 'Y'}">checked="checked"</c:if>>
												<label class="form-check-label" for="id_copy_yn_check">신분증사본</label>
											</div>
										</td>	
									</tr>
									<tr>
										<th class="text-right r1s">배송지</th>
										<td colspan="7">
											<div class="form-row inline-pd dc">
		                                        <div class="col-1 pdr0">
		                                            <input type="text" class="form-control mw45" readonly="readonly"
		                                                   id="delivery_post_no" name="delivery_post_no"
		                                                   value="${rent.delivery_post_no ? rent.delivery_post_no : rent_req.delivery_post_no}" alt="배송지 우편번호">
		                                        </div>
		                                        <div class="col-auto pdl5">
		                                            <button type="button" class="btn btn-primary-gra full"
		                                                    onclick="javascript:openSearchAddrPanel('fnSetArrival1Addr');">주소찾기
		                                            </button>
		                                        </div>
		                                        <div class="col-5">
		                                            <input type="text" class="form-control" readonly="readonly"
		                                                   id="delivery_addr1" name="delivery_addr1"
		                                                   value="${rent.delivery_addr1 ? rent.delivery_addr1 : rent_req.delivery_addr1}">
		                                        </div>
		                                        <div class="col-4">
		                                            <input type="text" class="form-control" id="delivery_addr2"
		                                                   name="delivery_addr2" value="${rent.delivery_addr2 ? rent.delivery_addr2 : rent_req.delivery_addr2}">
		                                        </div>
		                                    </div>											
										</td>
									</tr>
									<tr>
										<th class="text-right rs">실 사용지역</th>
										<td colspan="3">
											<div>
												<select class="form-control width130px rb inline" id="sale_area_code" name="sale_area_code" required="required" alt="실 사용지역">
													<option value="">- 선택 -</option>
													<c:forEach items="${areaList}" var="item">
														<option value="${item.sale_area_code}" <c:if test="${item.sale_area_code eq rent_req.sale_area_code}">selected="selected"</c:if>>${item.sale_area_name}</option>
													</c:forEach>
												</select>
											</div>
										</td>
										<th class="text-right rs">장비용도</th>
										<td>
											<div>
												<select class="form-control rb" id="mch_use_cd" name="mch_use_cd" required="required"alt="장비용도">
													<option value="">- 선택 -</option>
													<c:forEach items="${codeMap['MCH_USE']}" var="mchItem">
														<option value="${mchItem.code_value}" <c:if test="${mchItem.code_value eq rent_req.mch_use_cd}">selected="selected"</c:if>>${mchItem.code_name}</option>
													</c:forEach>
												</select>
											</div>
										</td>
										<th class="text-right">사용목적</th>
										<td>
											<div>
												<input type="text" class="form-control" maxlength="50" alt="" id="use_purpose" name="use_purpose" value="${rent.use_purpose ? rent.use_purpose : rent_req.use_purpose }">
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">임차구분</th>
										<td colspan="3">
											<div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="checkbox" id="norm_rental_yn" name="norm_rental_yn" value="Y" <c:if test="${rent.norm_rental_yn == 'Y' || rent_req.norm_rental_yn == 'Y'}">checked="checked"</c:if>>
													<label class="form-check-label" for="norm_rental_yn">일반</label>
												</div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="checkbox" id="long_rental_yn" value="Y" <c:if test="${rent.long_rental_yn == 'Y' || rent_req.long_rental_yn == 'Y'}">checked="checked"</c:if>>
													<label class="form-check-label" for="long_rental_yn">장기</label>
												</div>
											</div>
										</td>
										<th class="text-right">렌탈계산식</th>
										<td style="font-size: 11px" colspan="3">최종렌탈료=A+B-C+D (직배송 또는 선결제일 경우에만 D 합산)</td>
									</tr>
									<tr>
										<%-- <th class="text-right">최소렌탈료</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" readonly="readonly" id="min_rental_price" name="min_rental_price" format="decimal" value="${rent.min_rental_price }">
												</div>
												<div class="col width16px">원</div>
											</div>									
										</td> --%>
										<th class="text-right">장비렌탈료</th>
										<td colspan="3">
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" readonly="readonly" id="machine_rental_price" name="machine_rental_price" format="decimal" value="${rent.machine_rental_price ? rent.machine_rental_price : rent_req.machine_rental_price }">
												</div>
												<div class="col width16px">원</div>
												(A)
											</div>									
										</td>
										<th class="text-right">어태치렌탈료</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width80px">
													<input type="text" class="form-control text-right" readonly="readonly" id="attach_rental_price" name="attach_rental_price" format="decimal" value="${rent.attach_rental_price ? rent.attach_rental_price : rent_req.attach_rental_price}">
												</div>
												<div class="col width16px">원</div>
												(B)
											</div>									
										</td>
										<th class="text-right">장비보증금</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width80px">
													<input type="text" class="form-control text-right" id="mch_deposit_amt" name="mch_deposit_amt" format="minusNum" onchange="javascript:fnCalc()">
												</div>
												<div class="col width16px">원</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">총 렌탈료</th>
										<td colspan="3">
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" readonly="readonly" id="total_rental_amt" name="total_rental_amt" format="decimal" value="${rent.total_rental_amt  ? rent.total_rental_amt : rent_req.total_rental_amt}">
												</div>
												<div class="col width16px">원</div>
												(A+B)
											</div>									
										</td>
										<th class="text-right">렌탈료조정</th>
										<td colspan="3">
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" id="discount_amt" name="discount_amt" format="minusNum" value="${rent.discount_amt ? rent.discount_amt : rent_req.discount_amt}" onchange="javascript:fnCalc()">
												</div>
												<div class="col width16px">원</div>
												(C) 양수=할인, 음수=할증
											</div>									
										</td>
									</tr>
									<tr>
										<th class="text-right">운임비</th>
										<td colspan="3">
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" id="transport_amt" name="transport_amt" format="decimal" value="${rent.transport_amt ? rent.transport_amt : rent_req.transport_amt}" onchange="javascript:fnCalc()" disabled="disabled">
												</div>
												<div class="col width16px">원</div>
												<span style="color: red">(D) 직배송,선결제시 최종렌탈료에 합산</span>
											</div>
										</td>
										<th class="text-right">최종렌탈료</th>
										<td colspan="3">
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" readonly="readonly" id="rental_amt" name="rental_amt" format="decimal" value="${rent.rental_amt ? rent.rental_amt : rent_req.rental_amt}">
												</div>
												<div class="col width16px">원</div>
												<div style="margin-left: 5px;">VAT포함 :<div style="display: inline-block;"><input class="form-control" type="text" id="vat_rental_amt" name="vat_rental_amt" format="decimal" readonly="readonly"></div></div>
											</div>									
										</td>
									</tr>
									<tr>
										<th class="text-right">비고</th>
										<td colspan="3">
											<textarea class="form-control" style="height: 100%; min-height: 70px" id="remark" name="remark">${rent.remark }</textarea>
										</td>
										<th class="text-right rs">수익배분</th>
										<td colspan="3">
											<table style="border-collapse: collapse;">
												<colgroup>
													<col width="33.33%">
													<col width="33.33%">
												</colgroup>
												<tr>
													<td>
														<div style="display: inline-block;">안건자 (${shareRateMap.item_share_rate}%)</div>
														<input type="hidden" name="rental_profit_share_type_cd_01" value="01">
														<input type="hidden" name="profit_rate_01" value="${shareRateMap.item_share_rate}">
													</td>
													<td>
														<span>저장 후 반영됨</span>
													</td>
													<td>
														<div class="input-group">
															<input type="text" class="form-control border-right-0" id="profit_mem_name_01" name="profit_mem_name_01" placeholder="직원을조회하세요" readonly="readonly" style="background: white" alt="안건자">
															<input type="hidden" id="profit_mem_no_01" name="profit_mem_no_01" value="" required="required" alt="안건자">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMemberPanel('fnSetProfit01')"><i class="material-iconssearch"></i></button>
														</div>
													</td>
												</tr>
												<tr>
													<td>
														<div style="display: inline-block;">${SecureUser.kor_name} (${shareRateMap.contract_share_rate}%)</div>
														<input type="hidden" name="rental_profit_share_type_cd_02" value="02">
														<input type="hidden" name="profit_rate_02" value="${shareRateMap.contract_share_rate}">
													</td>
													<td>
														<span>저장 후 반영됨</span>
													</td>
													<td>
														<div class="input-group">
															<input type="text" class="form-control border-right-0" id="profit_mem_name_02" name="profit_mem_name_02" placeholder="직원을조회하세요" readonly="readonly" style="background: white" alt="계약자">
															<input type="hidden" id="profit_mem_no_02" name="profit_mem_no_02" value="" required="required" alt="계약자">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMemberPanel('fnSetProfit02')"><i class="material-iconssearch"></i></button>
														</div>
													</td>
												</tr>
												<tr>
													<td>
														<div style="display: inline-block;">출고자 (${shareRateMap.out_share_rate}%)</div>
														<input type="hidden" name="rental_profit_share_type_cd_03" value="03">
														<input type="hidden" name="profit_rate_03" value="${shareRateMap.out_share_rate}">
													</td>
													<td>
														<span>저장 후 반영됨</span>
													</td>
													<td>
														<div class="input-group">
															<input type="text" class="form-control border-right-0" id="profit_mem_name_03" name="profit_mem_name_03" placeholder="직원을조회하세요" readonly="readonly" style="background: white" alt="출고자">
															<input type="hidden" id="profit_mem_no_03" name="profit_mem_no_03" value="" required="required" alt="출고자">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMemberPanel('fnSetProfit03')"><i class="material-iconssearch"></i></button>
														</div>
													</td>
												</tr>
<%--											   <c:forEach items="${codeMap['RENTAL_PROFIT_SHARE_TYPE']}" var="item">--%>
<%--											      <tr>--%>
<%--											         <td>--%>
<%--											            <div style="display: inline-block;">${item.code_name} (${item.code_v1 }%)</div>--%>
<%--											            <input type="hidden" name="rental_profit_share_type_cd_${item.code_value}" value="${item.code_value}">--%>
<%--											            <input type="hidden" name="profit_rate_${item.code_value}" value="${item.code_v1}">--%>
<%--											         </td>--%>
<%--											         <td>--%>
<%--											         	<span>저장 후 반영됨</span>--%>
<%--											         </td>--%>
<%--											         <td>--%>
<%--											         	<div class="input-group">--%>
<%--&lt;%&ndash;															<select class="form-control width130px rb inline" id="profit_org_code_${item.code_value}" name="profit_org_code_${item.code_value}" required="required" alt="${item.code_name}">&ndash;%&gt;--%>
<%--&lt;%&ndash;																<option value="">- 선택 -</option>&ndash;%&gt;--%>
<%--&lt;%&ndash;																<c:forEach items="${orgCenterList}" var="listItem">&ndash;%&gt;--%>
<%--&lt;%&ndash;																	<option value="${listItem.org_code}" <c:if test="${(item.code_value eq '01' and listItem.org_code eq SecureUser.org_code) or (item.code_value ne '01' and listItem.org_code eq rent.mng_org_code)}">selected="selected"</c:if>>${listItem.org_name}</option>&ndash;%&gt;--%>
<%--&lt;%&ndash;																</c:forEach>&ndash;%&gt;--%>
<%--&lt;%&ndash;															</select>&ndash;%&gt;--%>
<%--																<input type="text" class="form-control border-right-0" id="profit_mem_name_${item.code_value}" name="profit_mem_name_${item.code_value}" placeholder="직원을조회하세요" readonly="readonly" style="background: white" alt="${item.code_name}">--%>
<%--																<input type="hidden" id="profit_mem_no_${item.code_value}" name="profit_mem_no_${item.code_value}" value="" required="required" alt="${item.code_name}">--%>
<%--																<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMemberPanel('fnSetProfit${item.code_value}')"><i class="material-iconssearch"></i></button>--%>
<%--														</div>--%>
<%--											         </td>--%>
<%--											      </tr>--%>
<%--											   </c:forEach>--%>
											</table>
										</td>
									</tr>
								</tbody>
							</table>
<!-- /렌탈정보 -->	
						</div>
						<div class="col-6">
<!-- 어태치먼트 -->
							<div class="title-wrap">
								<h4>어태치먼트</h4>
<%--								<div style="display: flex;">--%>
<%--									<div style="line-height: 2; margin-right: 5px">[기본수량]</div>--%>
<%--									<div>--%>
<%--										<span style="margin-right: 3px; line-height: 2"> 대</span>--%>
<%--										<input type="text" class="form-control width24px cInput" id="big_bucket_cnt" name="big_bucket_cnt" alt="대버켓 숫자" value="${rent.big_bucket_cnt}" datatype="int">--%>
<%--									</div>--%>
<%--									<div class="vl">|</div>--%>
<%--									<div>--%>
<%--										<span style="margin-right: 3px; line-height: 2"> 중</span>--%>
<%--										<input type="text" class="form-control width24px cInput" id="mid_bucket_cnt" name="mid_bucket_cnt" alt="중버켓 숫자" value="${rent.mid_bucket_cnt}" datatype="int">--%>
<%--									</div>--%>
<%--									<div class="vl">|</div>--%>
<%--									<div>--%>
<%--										<span style="margin-right: 3px; line-height: 2"> 소</span>--%>
<%--										<input type="text" class="form-control width24px cInput" id="sml_bucket_cnt" name="sml_bucket_cnt" alt="소버켓 숫자" value="${rent.sml_bucket_cnt}" datatype="int">--%>
<%--									</div>--%>
<%--									<div class="vl">|</div>--%>
<%--									<div>--%>
<%--										<span style="margin-right: 3px; line-height: 2"> 키</span>--%>
<%--										<input type="text" class="form-control width24px cInput" id="key_cnt" name="key_cnt" alt="키 숫자" value="${rent.key_cnt}" datatype="int">--%>
<%--									</div>--%>
<%--								</div>--%>
								<button type="button" class="btn btn-primary-gra" onclick="javascript:goAttachPopup();">어테치먼트 현황</button>
							</div>
							<div style="margin-top: 5px; height: 336px;" id="auiGrid"></div>					
<!-- /어태치먼트 -->
						<!-- 계약정보 -->
							<div class="title-wrap mt5">
								<h4>계약정보</h4>
								<div class="right">
									<div class="text-warning ml5">
										※ 전자계약은 어테치먼트까지 선택 완료 후 &lt;발송&gt;하시기 바랍니다
									</div>
								</div>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right">전자계약</th>
									<td>
										<div class="input-group">
											<c:if test="${page.add.MODUSIGN_YN eq 'Y'}">
												<button type="button" class="btn btn-primary-gra mr5"  onclick="javascript:sendModusignPanel()">발송</button>
												<button type="button" class="btn btn-primary-gra"  onclick="javascript:sendContactModusignPanel()">고객앱전송</button>
											</c:if>
										</div>
									</td>
									<th class="text-right">종이계약서</th>
									<td>
										<div class="paper_file_div">
										</div>
										<button type="button" class="btn btn-primary-gra" id="paperFileBtn" onclick="javascript:fnAddFile()" >파일찾기</button>
									</td>
								</tr>
								</tbody>
							</table>
						<!-- /계약정보 -->
						</div>
					</div>
					<div class="btn-group mt10">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>										
			</div>	
		</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>