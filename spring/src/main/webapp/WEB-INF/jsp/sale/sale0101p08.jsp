<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 출하처리
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48

★ 2020-08-31 회의내용 아래 내용 반영해서 출하처리 개발할것..
1. 출하처리 시, 은행명~계정 구분 (2018년 자료부터 없음), 계정구분 외상 아닌 자료 없음(셀렉트박스x -> span으로변경, 내부적으로 입금액 0원 처리), 사업자번호 확인 체크 추가, 변경을 비롯해서 ASIS에 있는 기능 다 추가
2. 품의서에 유상 사업자번호 있으면 유상부품 전표처리 시, 이걸 사업자번호로 하고 아니면 고객 사업자번호로 함. -> 유상사업자는 고객등록되있지않아서 예외
3. 무상전표에서 운임비 컬럼에 넣고, tobe에선 부품으로 처리안함.
4. 출하처리(무상), 출하처리(유상) 이런식으로 메뉴명 바꿔서 보여줌.. 무상끊고 팝업 다시 열어서 유상 전표 끊는건 동일
5. 출하의뢰서에 전표 보여줄때, 장비전표, 부품전표(무상, 유상, 추가) 발행안한건 버튼명 전표발행으로 함
6. 송장 주소 3개로
7. 추가출고처리와 출하처리 페이지 하나로 하고, 파라미터로 분기(추가출고처리 시, 운임비 컬럼 hide)

* 사업자번호 변경 팝업 -> 사업자번호 전체 조회팝업에서 선택

-- 이전 로직(사용안하는 로직) : resOrgCd가 4000일 경우(품의작성자의 조직코드가 4000일 경우 무상이든 유상이든 0원처리.. 유무상 가격 상관없이.. 그리드에 유무상 가격은 나와야함, 전표 총 가격만 0원)
-- 2020-12-17 일 로직 : 유정은 파트장 리뷰 = 무상은 대리점 본사 상관없이 무조건 0원, 유상은 고객에게 청구, 대리점 운임비는 고객에게 유상 청구 안함! 무조건 대리점에게 청구,,,, 
-- 추가출고도 동일함(유상, 무상 따로)
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var isNotAvailable = false;
		var partTotalAmt = 0;
		var agencyAmt = 0; 
	
		$(document).ready(function() {
			createAUIGrid();
			fnPageInit();
		});
		
		function fnPageInit() {
			if ("${outDoc.resultMessage}" != "") {
				alert("${outDoc.resultMessage}");
				fnClose();
				return false;
			};
			if ("${inputParam.inout_doc_no}" != "") {
				$("#_goSave").css("display", "none");
			}
			// 23.01.12 정윤수 Q&A 14448 매출처리 처리구분이 현금영수증, 카드매출, 무증빙인 경우 세금계산서 버튼 미노출
			if("${outDoc.vat_treat_cd}" == "A" || "${outDoc.vat_treat_cd}" == "C" || "${outDoc.vat_treat_cd}" == "N" ) {
				$("#_goTaxbill").css("display", "none");
			}
			var list = AUIGrid.getGridData(auiGrid);
			for (var i = 0; i < list.length; ++i) {
				if (list[i].cost_yn == "Y") {
					partTotalAmt+=$M.toNum(list[i].amt);	
				}
				// 매출정지일 경우 처리불가
				if (list[i].part_mng_cd == "9") {
					isNotAvailable = true;
				}
			}
			
			$M.setValue("doc_amt", partTotalAmt);
			var length = 0;
			try {
				length = list.length;	
			} catch (e) {
				console.error(e);
			}
			$("#total_cnt").html(length);
			fnCalc();
		} 
		
		// 문자발송
        function fnSendSms() {
            var param = {
                'name': $M.getValue('cust_name'),
                'hp_no': $M.getValue('hp_no')
            }
            openSendSmsPanel($M.toGetParam(param));
        }
        
		function fnCalc() {
			if ("${outDoc.inout_doc_no}" != "") {
				return false;
			}
			var amount = partTotalAmt; // asis amount
			/* amount += $M.toNum($M.getValue("agency_transport_amt")); */
			var discount = $M.toNum($M.getValue("discount_amt")); // asis discount
			var vat = parseInt((amount - discount) / 10); // asis vatmoney
			var total = amount - discount + vat; // asis totalmoney
			
			var param = {
				doc_amt : amount,
				discount_amt : discount,
				vat_amt : vat,
				total_amt : total
			}
			
			$M.setValue(param);
		}
		
		// 유상 품의서있을때(사업자 조회)
		function fnOpenBregInfoWhenPaid() {
			var param = {
		   	};
		   	openSearchBregInfoPanel('fnSetBregInfo', $M.toGetParam(param));
		}
		
		// 일반 사업자번호 변경(고객사업자번호 명세)
		function fnOpenBregInfo() {
		   	var param = {
	   			's_cust_no' : $M.getValue('cust_no')
		   	};
		   	openSearchBregSpecPanel('fnSetBregInfo', $M.toGetParam(param));
		}
		
		// 사업자정보조회 결과
      	function fnSetBregInfo(row) {
      		if (row.real_breg_no != null && row.real_breg_no != "") {
         		row.breg_no = row.real_breg_no; 
         	}
         	var param = {
         		breg_seq : row.breg_seq,
         		breg_no : row.breg_no,
         		breg_cor_type : row.breg_cor_type,
         		breg_cor_part : row.breg_cor_part,
         		breg_seq : row.breg_seq,
         		breg_rep_name : row.breg_rep_name,
         		breg_name : row.breg_name,
         		biz_post_no : row.biz_post_no,
         		biz_addr1 : row.biz_addr1,
         		biz_addr2 : row.biz_addr2
         	}
         	$M.setValue(param);
      	}
		
		function fnClose() {
			window.close();
		}
		
		// 서버 요청 gridFrm 백업
		var back_gridFrm;
		function goSave() {
			if ("${outDoc.resultMessage}" != "") {
				alert("${outDoc.resultMessage}");
				return false;
			}
			if ("${outDoc.type}" != "MF") {
				if (AUIGrid.getGridData(auiGrid).length == 0) {
					alert("부품이 없습니다.");
					return false;
				}
			}
			if ($M.validation(document.main_form) == false) {
				return false;
			}
			if (isNotAvailable == true) {
				alert("매출정지 부품을 처리하신 후 저장 하시기 바랍니다.");
				return false;
			}
			var frm = $M.toValueForm(document.main_form);
    		var concatCols = [];
    		var concatList = [];
    		var gridIds = [auiGrid];
    		for (var i = 0; i < gridIds.length; ++i) {
    			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
    			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
    		}
        	var gridFrm = fnGridDataToForm(concatCols, concatList);

        	$M.copyForm(gridFrm, frm);
        	var msg = "저장하시겠습니까?";
        	if ("${inputParam.type}".indexOf("A") > -1) {
        		msg = "전표일자를 확인후 처리하세요\n처리하시겠습니까?";
        	};

			// 출하처리(무상푸붐) 타입인 경우 모두싸인 발송 팝업 오픈
			if ("MF" == "${outDoc.type}") {
				// 데이터 임시 저장
				back_gridFrm = gridFrm;
				sendModusignPanel();
			} else {
				$M.goNextPageAjaxMsg(msg, this_page+"/save", gridFrm, {method: 'post', timeout : 60 * 60 * 1000}, // 타임아웃 1시간
					function (result) {
						if (result.success) {
							if ("MF" == "${outDoc.type}") {
								opener.goCallbackByMf();
								fnClose();
							} else {
								opener.location.reload();
								setTimeout(function () {
									fnClose();
								}, 100);
							}
						}
					}
				);
			}
		}
		
		// 출하처리 and 모두싸인 요청 함수 호출
		function goSaveAndModuSignAjax(param) {
			// 24.01.19 그리드 데이터 제대로 못넘겨받아서 추가
			var frm = $M.toValueForm(document.main_form);
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			var gridFrm = fnGridDataToForm(concatCols, concatList);

			$M.copyForm(gridFrm, frm);

			// 백업된 데이터로 출하 요청
			// 1. 출하처리 요청
			$M.goNextPageAjax(this_page+"/save", gridFrm, {method: 'post', timeout : 60 * 60 * 1000}, // 타임아웃 1시간
				function (result) {
					if (result.success) {
            var driverParam = {
              'sign_file_seq' : param.sign_file_seq,
              'driver_name' : param.trans_send_name,
              'driver_hp_no' : param.trans_send_hp_no,
              'driver_car_no' : param.trans_send_car_no,
              'machine_out_doc_seq' : param.machine_out_doc_seq
            }

            // 2. 운송자 정보 저장
            $M.goNextPageAjax("/sale/sale0101p03/save/driverInfo", $M.toGetParam(driverParam), {method: 'POST'},
              function (result) {
                if (result.success) {
                  // 3. 장비인수 모두싸인 요청
                  $M.goNextPageAjax("/modu/request_document", $M.toGetParam(param), {method : 'POST'},
                    function(result) {
                      if(result.success) {
                        opener.goCallbackByMf();
                        fnClose();
                      } else {
                        alert("출하처리는 완료되었지만 장비인수증 요청은 실패했습니다.");
                        opener.goCallbackByMf();
                        fnClose();
                      }
                    }
                  );
                } else {
                  alert("출하처리는 완료되었지만 장비인수증 요청은 실패했습니다.");
                  opener.goCallbackByMf();
                  fnClose();
                }
              });
					}
				}
			);
		}

		// 모두싸인 콜백
		function moduSignPanelCallBack(data) {
			var param = {
				machine_out_doc_seq: $M.getValue('machine_out_doc_seq'),
				machine_doc_no: $M.getValue('machine_doc_no'),
				modusign_doc_cd: 'MCH_OUT_DOC',
				// 인수자
				modusign_send_cd: data.modusign_send_cd,
				send_hp_no: data.modusign_send_value,
				send_email: data.modusign_send_value,
				// 운송자
        trans_send_name : data.trans_send_name,
        trans_send_hp_no : data.trans_send_hp_no,
        trans_send_car_no : data.trans_send_car_no,
        sign_file_seq : data.sign_file_seq,
			};
			
			// 출하처리 and 모두싸인 요청 함수 호출
			goSaveAndModuSignAjax(param);
		}

		// 모두싸인 대면요청 (저장 후 진행)
		function sendModusignPanel() {
			<c:if test="${not empty inputParam.modu_sign_data}">
				var params = {...${inputParam.modu_sign_data}};
				openSendModusignPanel('moduSignPanelCallBack', $M.toGetParam(params));
			</c:if>
		}
		
		function goReceipt() {
			if ("${outDoc.inout_doc_no}" == "") {
				alert("전표를 먼저 발행하세요");				
			} else {
				openReportPanel('cust/cust0202p01_01.crf','inout_doc_no=' + "${outDoc.inout_doc_no}");
			}
		}
		
		function goInvoice() {
			if ("${inputParam.type}".indexOf("A") == -1) {
				if ("${outDoc.inout_doc_no}" == "") {
					alert("전표를 먼저 발행하세요");
					return false;
				}	
			}
			var param = {
				cust_no : "${outDoc.cust_no}",
				receive_hp_no : $M.getValue("receive_hp_no") == "" ? "${outDoc.hp_no}" : $M.getValue("receive_hp_no"),
				receive_tel_no : $M.getValue("receive_tel_no") == "" ? "${outDoc.tel_no}" : $M.getValue("receive_tel_no"),
				receive_name : $M.getValue("receive_name}") == "" ? "${outDoc.cust_name}" : $M.getValue("receive_name"),
				invoice_send_cd : $M.getValue("invoice_send_cd"),
				invoice_type_cd : "08",
				invoice_money_cd : $M.getValue("invoice_money_cd"),
				invoice_no : $M.getValue("invoice_no"),
				qty : $M.getValue("invoice_qty"),
				remark : $M.getValue("invoice_remark"),
				post_no : $M.getValue("invoice_post_no"),
    			addr1 : $M.getValue("invoice_addr1"),
    			addr2 : $M.getValue("invoice_addr2"),
    			inout_doc_no : "${outDoc.inout_doc_no}"
			}
			openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(param));
		}
		
		function setDeliveryInfo(row) {
			// console.log(row);
			var param = {
				send_invoice_seq : "${outDoc.send_invoice_seq}",
				cust_no : "${outDoc.cust_no}",
				inout_doc_no : "${outDoc.inout_doc_no}",
				send_invoice_seq : "${invoice.send_invoice_seq}",
				invoice_send_cd : row.invoice_send_cd,
				receive_name : row.receive_name,
				receive_hp_no : row.receive_hp_no,
				receive_tel_no : row.receive_tel_no,
				invoice_no : row.invoice_no,
				invoice_qty : row.invoice_qty,
				invoice_money_cd : row.invoice_money_cd,
				invoice_remark : row.invoice_remark,
				invoice_post_no : row.invoice_post_no,
				invoice_addr1 : row.invoice_addr1,
				invoice_addr2 : row.invoice_addr2
			}
			// console.log("여기", param);
			if ("${inputParam.type}".indexOf("A") == -1) {
				$M.goNextPageAjax(this_page+"/invoice", $M.toGetParam(param), {method: 'post'},
		                  function (result) {
								console.log(result);
		                       if (result.success) {
		                    	   window.location.reload();
		                       }
		                  }
		             );
			} else {
				$M.setValue(param);
			}
		}
		
		function goTaxbill() {
			if ("${outDoc.inout_doc_no}" == "") {
				alert("전표를 먼저 발행하세요");				
			} else {
				var param = {
	            	inout_doc_no : "${outDoc.inout_doc_no}",
	            	type : "part"
	            }
	            var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=375, height=340, left=0, top=0";
	            $M.goNextPage('/sale/sale0101p05', $M.toGetParam(param), {popupStatus : poppupOption});
			}
		}
		
		function goARS() {
			var param = {
				cust_no : "${outDoc.cust_no}"
			}
			var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=375, height=340, left=0, top=0";
            $M.goNextPage('/comp/comp0703', $M.toGetParam(param), {popupStatus : poppupOption});
			
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				showFooter : true,
				footerPosition : "top",
				rowIdField : "_$uid",
				editable: "${inputParam.type}".indexOf("A") > -1 ? true : false,
				height : 165
			};
			var columnLayout = [
				{ 
					headerText : "구분", 
					dataField : "inout_item_type_name", 
					width : "6%", 
					style : "aui-center",
					editable : false,
					/* labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = "";
						switch (value) {
							case 0: ret = "운임"; break;
							case 1: ret = "옵션"; break;
							case 2: ret = "기본"; break;
							case 3: ret = "버킷"; break;
							case 4: ret = "추가"; break;
						} 
					    return ret; 
					} */
				},
				{ 
					headerText : "유무상", 
					dataField : "free_yn",
					width : "6%",  
					editable : false,
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = "";
						switch (value) {
							case "Y": ret = "무상"; break;
							case "N": ret = "유상"; break;
						} 
					    return ret; 
					}
				},
				{
					headerText : "부품번호", 
					dataField : "item_id", 
					editable : false,
					style : "aui-left"
				},
				{ 
					headerText : "부품명", 
					dataField : "item_name", 
					editable : false,
					style : "aui-left",
				},
				{ 
					headerText : "수량", 
					dataField : "qty", 
					width : "6%", 
					editable: "${inputParam.type}".indexOf("A") > -1 ? true : false,
					style : "aui-center",
					editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true,
                        allowPoint: false,
                        validator: function (ov, nv, item, dataField) {
                            var newValue = parseInt(nv);
                            var oldValue = parseInt(ov);
                            var origin_qty = parseInt(item.origin_qty);
                            var msg = "";
                            var isValid = true;
                            if (newValue > origin_qty) {
                                isValid = false;
                                msg = "지급 수량보다 입력된 수량이 많습니다.";
                            } else {
                                isValid = true;
                            }
                            /* if (newValue < 0) {
                            	isValid = false;
                            	msg = "0보다 작을 수 없습니다.";
                            } else {
                            	if (newValue > qty) {
                                    isValid = false;
                                    msg = "지급품 수량보다 클 수 없습니다.";
                                } else {
                                    isValid = true;
                                }
                            } */
                            return {"validate": isValid, "message": msg};
                        }
                    }
				},
				{ 
					headerText : "단가", 
					dataField : "unit_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%", 
					editable : false,
					style : "aui-right",
				},
				{ 
					headerText : "금액", 
					dataField : "amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "8%", 
					editable : false,
					style : "aui-right",
				},
				// {
				// 	headerText : "현재고",
				// 	dataField : "stock_qty",
				// 	width : "6%",
				// 	editable : false,
				// 	style : "aui-center",
				// },
				{
					headerText : "가용재고",
					dataField : "current_able_stock",
					width : "6%",
					editable : false,
					style : "aui-center",
				},
				{ 
					headerText : "관리구분", 
					dataField : "part_mng_name", 
					width : "10%",
					editable : false,
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = "";
						if (item.gubun == 0) {
							ret = "비부품";
						} else {
							ret = value;
						}
					    return ret; 
					}
				},
				{
					dataField : "part_mng_cd",
					visible : false
				},
				{
					dataField : "cost_yn", // 유무상과 반대 -> free면 cost N
					visible : false
				},
				{
					dataField : "current_all_qty",
					visible : false
				},
				{
					dataField : "in_price",
					visible : false
				},
				{
					dataField : "inout_item_type_cd",
					visible : false
				},
				{
					dataField : "item_desc_text",
					visible : false
				},
				{
					dataField : "origin_qty",
					visible : false
				},
				{
					dataField : "seq_no",
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "part_option"
				},{
					dataField : "center",
					positionField : "center",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, ${partList});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.dataField == "stock_qty") {
					var param = {
						part_no : event.item.item_id
					}
					var popupOption1 = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1050, height=650, left=0, top=0";
					$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption1});
				}
			});
			AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
            	if (event.dataField == "qty") {
            		partTotalAmt = 0;
            		if (event.item.cost_yn == "Y") {
            			AUIGrid.updateRow(auiGrid, {
    						amt : event.value * event.item.unit_price
    					}, event.rowIndex);	
            		}
            		
            		
            		var list = AUIGrid.getGridData(auiGrid);
        			for (var i = 0; i < list.length; ++i) {
        				if (list[i].cost_yn == "Y") {
        					partTotalAmt+=$M.toNum(list[i].amt);	
        				}
        			}
            		fnCalc();
                }
            });
			$("#auiGrid").resize();
		}
		
		function fnSetOutOrgCode(row) {
			var param = {
				inout_org_code : row.org_code,
				inout_org_name : row.org_name
			};
			$M.setValue(param);
		}

		function fnSetCenter(){
			var param = {
				s_part_org_yn : "Y",
			}
			openOrgMapCenterPanel('fnSetOutOrgCode', $M.toGetParam(param));
		}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="machine_out_doc_seq" id="machine_out_doc_seq" value="${inputParam.machine_out_doc_seq }">
<input type="hidden" name="cust_no" id="cust_no" value="${cust_no}"> <!-- 전표 고객번호, asis customerid -->
<input type="hidden" name="real_cust_no" id="real_cust_no" value="${outDoc.real_cust_no }"><!-- 품의서 고객번호, asis customerid2 -->
<input type="hidden" name="machine_doc_no" id="machine_doc_no" value="${outDoc.machine_doc_no}">
<input type="hidden" name="type" id="type" value="${outDoc.type}">
<input type="hidden" name="breg_seq" id="breg_seq" value="${outDoc.breg_seq }">
<input type="hidden" name="cust_fax_no" id="cust_fax_no" value="${outDoc.fax_no}">
<input type="hidden" name="res_org_code" id="res_org_code" value="${outDoc.res_org_code}">

<input type="hidden" name="paid_breg_yn" id="paid_breg_yn" value="${paid_breg_yn}">

<!-- 팝업 -->
    <div class="popup-wrap width-100per" style="min-width: 1000px">
<!-- 타이틀영역 -->
        <div class="main-title">
             <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap" style="min-width: 950px;">	
				<div class="title-wrap">
					<h4 class="primary">출하처리<c:choose><c:when test="${'MF' eq outDoc.type}">(무상부품)</c:when><c:when test="${'P' eq outDoc.type}">(유상부품)</c:when><c:when test="${'AP' eq outDoc.type}">(유상추가출고)</c:when><c:when test="${'AF' eq outDoc.type}">(무상추가출고)</c:when></c:choose></h4>
					<div style="text-align: right;">
					<button class="btn btn-md btn-rounded btn-outline-primary" onclick="javascript:goReceipt()">거래명세서</button>
					<button class="btn btn-md btn-rounded btn-outline-primary" id="_goTaxbill" onclick="javascript:goTaxbill()">세금계산서</button>
					</div>
				</div>
<!-- 폼테이블 -->
				<div class="row">
<!-- 좌측 폼테이블-->
					<div class="col-6" style="min-width: 465px">
						<div>
							<table class="table-border mt5">
								<colgroup>
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">관리번호</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col">
													<input type="text" class="form-control" readonly="readonly" value="${outDoc.machine_doc_no}">
												</div>
												<%-- <div class="col-auto">-</div>
												<div class="col-5">
													<input type="text" class="form-control" readonly="readonly" value="${fn:substring(outDoc.machine_doc_no,5,9)}">
												</div> --%>
												<input type="hidden" name="machine_doc_no" id="machine_doc_no" value="${outDoc.machine_doc_no }">
											</div>
										</td>
										<th class="text-right">전표일자</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" value="${outDoc.inout_dt}" dateFormat="yyyy-MM-dd" id="inout_dt" name="inout_dt" 
												<c:if test="${inputParam.type.indexOf('A') eq -1}">disabled="disabled"</c:if>>
												<c:if test="${'Y' eq outDoc.end_yn}">
													<div class="text-secondary" style="margin: 0 auto;line-height: 2;">마감완료</div>
												</c:if>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">모델명</th>
										<td>
											<input type="text" class="form-control" readonly="readonly" value="${outDoc.machine_name }" id="machine_name" name="machine_name">
											<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="${outDoc.machine_plant_seq}">		
										</td>	
										<th class="text-right">전표번호</th>
										<td>							
											<div class="form-row inline-pd">
												<div class="col-12">
													<input type="text" class="form-control" readonly="readonly" value="${outDoc.inout_doc_no }">
												</div>
												<!-- <div class="col-3">
													<input type="text" class="form-control" readonly="readonly">
												</div>
												<div class="col-auto">
													-
												</div>
												<div class="col-3">
													<input type="text" class="form-control" readonly="readonly">
												</div> -->
											</div>					
										</td>
									</tr>
									<tr>
										<th class="text-right">고객명</th>
										<td colspan="3">
											<div class="form-row inline-pd">
												<div class="col-4">
													<div >
														<input type="text" class="form-control " readonly="readonly" value="${outDoc.cust_name }" id="cust_name" name="cust_name">
														<!-- <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:alert('고객명조회');"><i class="material-iconssearch"></i></button> -->	
													</div>
												</div>
												<%-- <div class="col-4">
													<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name" placeholder="업체명" value="${outDoc.breg_name }">
												</div> --%>
												<div class="col-4">
													<div class="input-group">
														<input type="text" class="form-control border-right-0" readonly="readonly" placeholder="연락처" value="${outDoc.hp_no}" id="cust_hp_no" name="cust_hp_no" format="phone">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
													</div>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right rs">사업자번호</th>
										<td colspan="3">
											<div class="form-row inline-pd">
												<div class="col-4">
													<input type="text" class="form-control" readonly="readonly" id="breg_no" name="breg_no" value="${outDoc.breg_no }" placeholder="사업자번호" alt="사업자번호" required="required" format="bregno">
												</div>
												<div class="col-4">
													<div class="form-row inline-pd" style="margin: 0 auto">
														<div>
															<input type="checkbox" name="breg_confirm_yn" value="Y" id="breg_confirm_yn" required="required" alt="사업자 확인" 
															<c:if test="${not empty outDoc.inout_doc_no}">checked disabled</c:if>
															><label for="breg_confirm_yn" <c:if test="${empty outDoc.inout_doc_no}">style='color:red;'</c:if>> 사업자 확인</label>
														</div>
														<div style="padding-left: 5px">
															<c:if test="${empty outDoc.inout_doc_no}">
																<c:choose>
																	<c:when test="${not empty paid_breg_yn}">
																		<input class="btn btn-default" type="button" value="변경" onclick="javascript:fnOpenBregInfoWhenPaid('fnSetBregInfo')">
																	</c:when>
																	<c:otherwise>
																		<input class="btn btn-default" type="button" value="변경" onclick="javascript:fnOpenBregInfo('fnSetBregInfo')">	
																	</c:otherwise>
																</c:choose>
															</c:if>
														</div>
													</div>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">사업자</th>
										<td colspan="3">
											<div class="form-row inline-pd">
												<div class="col-4">
													<div>
														<input type="text" class="form-control" id="breg_rep_name" name="breg_rep_name" value="${outDoc.breg_rep_name }" readonly="readonly" placeholder="대표">
														<!-- <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:alert('고객명조회');"><i class="material-iconssearch"></i></button> -->	
													</div>
												</div>
												<div class="col-4">
													<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name" placeholder="업체명" value="${outDoc.breg_name }">
												</div>
												<div class="col-2">
													<input type="text" class="form-control" readonly="readonly" id="breg_cor_type" name="breg_cor_type" value="${outDoc.breg_cor_type}" placeholder="업태">
												</div>
												<div class="col-2">
													<input type="text" class="form-control" readonly="readonly" id="breg_cor_part" name="breg_cor_part" value="${outDoc.breg_cor_part}" placeholder="종목">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">주소</th>
										<td colspan="3">
											<div class="form-row inline-pd mb7">
												<div class="col-3">
													<input type="text" class="form-control" readonly="readonly" value="${outDoc.biz_post_no}" id="biz_post_no" name="biz_post_no">
												</div>
												<div class="col-9">
													<input type="text" class="form-control" readonly="readonly" value="${outDoc.biz_addr1}" id="biz_addr1" name="biz_addr1">
												</div>
											</div>
											<div class="form-row inline-pd">
												<div class="col-12">
													<input type="text" class="form-control" readonly="readonly" value="${outDoc.biz_addr2}" id="biz_addr2" name="biz_addr2">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">지역</th>
										<td>
											<input type="text" class="form-control" readonly="readonly" value="${outDoc.sale_area_name }" id="sale_area_name" name="sale_area_name">
											<input type="hidden" id="sale_area_code" name="sale_area_code" value="${outDoc.sale_area_code }">
										</td>
										<th class="text-right">매출한도</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.max_misu_amt }" id="max_misu_amt" name="max_misu_amt" format="decimal">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">쿠폰잔액</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.coupon_amt }" id="coupon_amt" name="coupon_amt" format="decimal">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
										<th class="text-right">현미수금액</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.misu_amt }" id="misu_amt" name="misu_amt" format="decimal">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div>
							<table class="table-border mt10">
							<colgroup>
								<col width="80px">
								<col width="">
							</colgroup>
							<tbody>					
								<tr>
									<th class="text-right">발송구분</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-2">
												<select class="form-control" id="invoice_send_cd" name="invoice_send_cd" alt="발송구분" disabled>
													<option value="">- 선택 -</option>
													<!-- <option value="5">대신화물</option>
													<option value="0">방문</option>
													<option value="1">한진택배</option>
													<option value="2">대신택배</option>
													<option value="3">퀵(오토바이)</option>
													<option value="4">다마스</option> -->
													<c:forEach items="${codeMap['INVOICE_SEND']}" var="item" varStatus="status">
														<option value="${item.code_value }" <c:if test="${ invoice.invoice_send_cd eq item.code_value }">selected="selected"</c:if>>${item.code_name }</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-auto">
												<button type="button" class="btn btn-primary-gra" onclick="javascript:goInvoice()">설정하기</button>
											</div>	
											<div class="col-5">
												<input type="hidden" id="invoice_post_no" name="invoice_post_no" value="${invoice.post_no }">
	                                            <input type="text" class="form-control" id="invoice_addr1" name="invoice_addr1" value="${invoice.addr1 }" readonly="readonly" style="background: white">
	                                        </div>
	                                        <div class="col-3">
	                                            <input type="text" class="form-control" id="invoice_addr2" name="invoice_addr2" value="${invoice.addr2 }" readonly="readonly" style="background: white">
	                                        </div>
	                                        <input type="hidden" id="invoice_no" name="invoice_no" value="${invoice.invoice_no}">
	                                        <input type="hidden" id="send_invoice_seq" name="send_invoice_seq" value="${invoice.send_invoice_seq}">
	                                        <input type="hidden" id="receive_name" name="receive_name" value="${invoice.receive_name}">
	                                        <input type="hidden" id="receive_tel_no" name="receive_tel_no" value="${invoice.receive_tel_no}">
	                                        <input type="hidden" id="receive_hp_no" name="receive_hp_no" value="${invoice.receive_hp_no}">
	                                        <input type="hidden" id="invoice_remark" name="invoice_remark" value="${invoice.remark}">
	                                        <input type="hidden" id="invoice_money_cd" name="invoice_money_cd" value="${invoice.invoice_money_cd}">
	                                        <input type="hidden" id="invoice_qty" name="invoice_qty" value="${invoice.qty }">
						               </div>
									</td>
								</tr>
							</tbody>
						</table>
						</div>
					</div>
<!-- 좌측 폼테이블-->		
<!-- 우측 폼테이블-->
					<div class="col-6" style="min-width: 465px">
						<div>
<!-- 처리창고 -->								
							<table class="table-border mt5">
								<colgroup>
									<col width="20%">
									<col width="30%">
									<col width="20%">
									<col width="30%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right rs">처리센터</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0" readonly="readonly" value="${outDoc.inout_org_name}" id="inout_org_name" name="inout_org_name" required="required" alt="처리센터">
												<input type="hidden" id="inout_org_code" name="inout_org_code" value="${outDoc.inout_org_code}">
												<button type="button" class="btn btn-icon btn-primary-gra" 
 												<c:if test="${not empty outDoc.inout_doc_no }">disabled</c:if>
												onclick="javascript:fnSetCenter();"><i class="material-iconssearch"></i></button>
											</div>
										</td>
										<th class="text-right">마케팅담당</th>
										<td>
											<input type="text" class="form-control" readonly="readonly" value="${not empty outDoc.reg_mem_name ? outDoc.reg_mem_name : SecureUser.kor_name }">
										</td>							
									</tr>
									<tr>
										<th class="text-right">물품대</th> <!-- 대리점운임비 -->
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<!-- 대리점운임비는 대리점에게만 청구하고, 고객에게는 청구안함!(무상에 넣어서 대리점전표에 들어가야함) -->
													<%-- <input type="text" class="form-control text-right" value="${outDoc.agency_transport_amt}" format="decimal" id="agency_transport_amt" name="agency_transport_amt" readonly="readonly"> --%>
													<input type="text" class="form-control text-right" value="${outDoc.doc_amt}" format="decimal" id="doc_amt" name="doc_amt" readonly="readonly"> <!-- 물품대(안보여줌) -->
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
										<th class="text-right">할인</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" <c:if test="${not empty outDoc.inout_doc_no }">disabled</c:if> class="form-control text-right" id="discount_amt" name="discount_amt" format="decimal" value="${outDoc.discount_amt }" onchange="fnCalc()">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>									
									</tr>
									<tr>
										<th class="text-right">부가세</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" class="form-control text-right" id="vat_amt" name="vat_amt" format="decimal" value="${outDoc.vat_amt}" onchange="fnCalc()" readonly="readonly">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
										<th class="text-right">합계금액</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" class="form-control text-right" id="total_amt" name="total_amt" value="${outDoc.total_amt}" format="decimal" onchange="fnCalc()" readonly="readonly">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>									
									</tr>
									<tr>
										<th class="text-right">입금액</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<!-- 외상 고정이라서 입금액 항상 0 -->
													<input type="text" class="form-control text-right" id="inout_amt" name="inout_amt" value="${outDoc.inout_amt}" onchange="fnCalc()" readonly="readonly">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
										<th class="text-right">계정구분</th>
										<td>
											<span>외상</span> <!-- 고정하기로함. 상단 주석참고 -->
											<%-- <select class="form-control" id="vcc_type_cd" name="vcc_type_cd">
												<c:forEach var="item" items="${codeMap['ACC_TYPE']}">
		                                            <option value="${item.code_value}">
		                                                    <c:if test="${outDoc.machine_send_cd == item.code_value}">selected="selected"</c:if>
		                                                    ${item.code_name}
		                                            </option>
		                                        </c:forEach>
											</select> --%>
											<span style="float:right">
												<%-- <c:choose>
														<c:when test="${uc:getControlCaseAt(item.sendcase, 6) eq '8' }">외상매출금지【장기미수】</c:when>
														<c:when test="${uc:getControlCaseAt(item.sendcase, 6) eq '9' }">외상매출금지</c:when>
														<c:otherwise>&nbsp;</c:otherwise>
													</c:choose>  --%>
												<c:choose>
													<c:when test="${'8' eq outDoc.deal_gubun_cd}">외상매출금지【장기미수】</c:when>
													<c:when test="${'9' eq outDoc.deal_gubun_cd}">외상매출금지</c:when>
													<c:otherwise>&nbsp;</c:otherwise>
												</c:choose>
											</span>
										</td>									
									</tr>
									<tr style="height: 67px">
										<th class="text-right">비고</th>
										<td>
											<textarea class="form-control" <c:if test="${not empty outDoc.inout_doc_no }">disabled</c:if> style="height:55px; resize: none;" id="remark" name="remark" maxlength="300">${outDoc.remark }</textarea>
										</td>
										<td colspan="2" rowspan="2" class="pd0">
											<div class="form-row inline-pd sm-table">
												<div class="col-3 th">
													입금자명 :
												</div>
												<div class="col-9 td">
													<input type="text" class="form-control" style="pointer-events: none;" tabindex="-1">
												</div>
											</div>
											<div class="form-row inline-pd sm-table">
												<div class="col-3 th">
													입금액 :
												</div>
												<div class="col-9 td">
													<input type="text" class="form-control" style="pointer-events: none;" tabindex="-1">
												</div>
											</div>
											<div class="form-row inline-pd sm-table">
												<div class="col-3 th">
													입금자 :
												</div>
												<div class="col-9 td">
													<input type="text" class="form-control" style="pointer-events: none;" tabindex="-1">
												</div>
											</div>
											<div class="form-row inline-pd sm-table">
												<div class="col-3 th">
													은행명 :
												</div>
												<div class="col-9 td">
													<input type="text" class="form-control" style="pointer-events: none;" tabindex="-1">
												</div>
											</div>
											<div class="form-row inline-pd sm-table">
												<div class="col-3 th">
													계좌번호 :
												</div>
												<div class="col-9 td border-n">
													<input type="text" class="form-control" style="pointer-events: none;" tabindex="-1">
												</div>
											</div>
										</td>									
									</tr>
									<tr style="height: 73px">
										<th class="text-right">적요</th>
										<td>
											<textarea class="form-control" <c:if test="${not empty outDoc.inout_doc_no }">disabled</c:if> style="height:55px; resize: none;" id="desc_text" name="desc_text" maxlength="300">${outDoc.desc_text }</textarea>
										</td>									
									</tr>
									
								</tbody>
							</table>
						</div>
<!-- /처리창고 -->	
<!-- 발송구분 -->									
						<table class="table-border mt10">
							<colgroup>
								<col width="20%">
								<col width="80%">
							</colgroup>
							<tbody>					
								<tr>
									<th class="text-right">최종메모</th>
									<td>
										<textarea type="text" class="form-control" size="20" maxlength="2000" style="height:61px" disabled="disabled">${outDoc.last_memo }</textarea>
									</td>								
								</tr>							
							</tbody>
						</table>
<!-- /발송구분 -->	
					</div>
<!-- 우측 폼테이블-->	
				</div>

<!-- 하단 폼테이블 -->
				<div class="title-wrap mt10">
					<h4>출하지급내역</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px;"></div>
<!-- /하단 폼테이블 -->
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">		
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
