<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 부품발주관리 > 발주등록 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			createAUIGrid(); // 메인 그리드
			
			if("${inputParam.machine_ship_plan_seq}" != "") {
				fnSetAttachOrder();
			}
		});
		
		// 어테치먼트 발주관리에서 부품발주서 등록 시 해당 부품 세팅
		function fnSetAttachOrder() {
			$M.setValue("machine_ship_plan_seq", "${inputParam.machine_ship_plan_seq}");
			
			var param = {
					"s_maker_cd" : "${inputParam.s_maker_cd}",
					"s_machine_ship_plan_seq" : "${inputParam.machine_ship_plan_seq}"
			};
			
			$M.goNextPageAjax("/part/part080102/searchAttach", $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			if(result.list.length != 0) {
			    			fnAddAttach(result.list);
		    			}
					}
				}
			);
			
		}
		
		function fnList() {
			 //$M.goNextPage("/part/part0403");
			window.close();
		}
		
		function goPartList() {
			var custNo = $M.getValue("cust_no");
			if (custNo == "") {
				alert("발주처를 선택하세요.");
				return false;
			}
			var param = {
	    		's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
				'confirm_yn' : "Y", // 23.02.28 정윤수 부품발주 부품추가 시 정상부품 아닌경우 confirm창 띄움
				's_deal_cust_no' : $M.getValue("cust_no"), // 23.03.02 정윤수 매입처에 따라 단가를 조회하기 위하여 추가
	    	};
			openSearchPartPanel('fnAddByPartView', 'Y', $M.toGetParam(param));
		}
		
		function fnAddByPartView(row) {
			var item = row[0];
			console.log(item);
			var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", item.part_no);
			if (rowItems.length != 0) {
				 return "부품번호가 중복됩니다.\n"+item.part_no;					 
			}
			item["seq_no"] = fnGetNextSeqNo();
			item["be0_out_total_qty"] = item.part_year;
			item["be1_out_total_qty"] = item.part_before1;
			item["be2_out_total_qty"] = item.part_before2;
			item["fixed_cnt"] = "";
			item["preorder_no_array"] = "";
			item["warehouse_cd_array"] = "";
			item["assign_center_name_str"] = "";
			item["assign_qty_array"] = "";
			item["assign_str"] = "";
			item["remark"] = "";
			item["preorder_inout_doc_no_str"] = "0";
			if(item["special_price"] != null && item["special_price"] != "" && item["special_price"] != "0"){
				item["unit_price"] = item["special_price"];
			}
			// 계약납기일 일수(발주등록일에서 addDate해서 계약납기일을 구한다, ex: 90일이면, 발주일+90일이 날짜가 계약납기일)
    		item["delivary_dt"] = $M.dateFormat($M.addDates($M.toDate($M.getValue("current")), $M.toNum(item.delivary_cnt)), 'yyyy-MM-dd');
			AUIGrid.addRow(auiGrid, item, 'last');
		}
		
		function fnClose() {
			window.close();
		}
		
		function fnGetNextSeqNo() {
			var grid = AUIGrid.getGridData(auiGrid);
			var seq = grid.length != 0 ? grid[grid.length-1].seq_no : 0;
			var plusSeq = $M.toNum(seq)+1;
			return plusSeq;
		}
		
		// 부품번호 강제선택
		function fnSetSelection() {
			var lastRow = AUIGrid.getGridData(auiGrid).length-1;
    		AUIGrid.setSelectionByIndex(auiGrid, lastRow, 9);
		}
		
		function fnAddAttach(list) {
			var itemArr = [];
			for (var i = 0; i < list.length; ++i) {
				// 그리드에 add
				var item = new Object();
	    		item.part_no = list[i].part_no;
	    		item.part_name = list[i].part_name;
				// item.unit_price = list[i].unit_price == null ? "0" : list[i].unit_price;
				// 24.01.04 special_price가 있으면 special_price를 단가로 보여주기 위하여 추가
				var temp_total = "";
				if(list[i].special_price != null && list[i].special_price != "0") {
					item.unit_price = list[i].special_price
					temp_total = Number(list[i].request_order_qty) * Number(list[i].special_price);
				} else {
					item.unit_price = list[i].unit_price == null ? "0" : list[i].unit_price;
					temp_total = Number(list[i].request_order_qty) * Number(list[i].unit_price);
				}
	    		item.current_stock = list[i].current_stock;
	    		item.part_mng_name = list[i].part_mng_name;
	    		// 발주요청자료 참조입력 시, 요청수량 밑으로 입력안되게
	    		item.fixed_cnt = list[i].fixed_cnt;
	    		// var temp_total = Number(list[i].request_order_qty) * Number(list[i].unit_price);
	    		item.total_price = temp_total.toFixed(2);
	    		// 발주등록 시, 요청수량이 주문수량=심사수량=승인수량
	    		item.order_qty = list[i].request_order_qty;
	    		item.check_qty = list[i].request_order_qty;
	    		item.approval_qty = list[i].request_order_qty;
	    		
	    		item.money_unit_cd = list[i].money_unit_cd;
	    		item.be0_out_total_qty = list[i].be0_out_total_qty;
	    		item.be1_out_total_qty = list[i].be1_out_total_qty;
	    		item.be2_out_total_qty = list[i].be2_out_total_qty;
	    		item.part_name_change_yn = list[i].part_name_change_yn;
	    		
	    		// 계약납기일 일수(발주등록일에서 addDate해서 계약납기일을 구한다, ex: 90일이면, 발주일+90일이 날짜가 계약납기일)
	    		item.delivary_dt = $M.dateFormat($M.addDates($M.toDate($M.getValue("current")), $M.toNum(list[i].delivary_cnt)), 'yyyy-MM-dd');
	    		// 자동 할당
	    		var center_cd_arr = [];
	    		var center_name_arr = [];
				var request_order_qty_arr = []; 
				var preorder_no_arr = [];
				var cust_arr = [];
				var buttonText = "";
				var custText = "";
				var tempBtnName = center_name_arr;
				if (tempBtnName.length > 1) {
					var remain = tempBtnName.length-1;
					buttonText = tempBtnName[0] + " 외 "+remain;
				} else {
					buttonText = tempBtnName[0];
				}
				if (cust_arr.length > 1) {
					var remain = cust_arr.length-1;
					custText = cust_arr[0] + " 외 "+remain;
				} else {
					custText = cust_arr[0];
				}
				item.button_text = buttonText;
				custText = custText != undefined ? "/"+custText : "";
				item.remark = "";
				item.preorder_inout_doc_no_str = "0";
				item.preorder_no_str = $M.getArrStr(preorder_no_arr);
	    		item.warehouse_cd_array = $M.getArrStr(center_cd_arr, {sep : "^"});
	    		item.assign_center_name_str = $M.getArrStr(center_name_arr, {sep : "^"});
	    		item.assign_qty_array = $M.getArrStr(request_order_qty_arr, {sep : "^"});
	    		item.assign = "";
	    		// 최종 그리드에 담을 아이템
	    		itemArr.push(item);
				// 합계수량과 합계금액 갱신			    		
	    		total_amt+=Number(item.total_price);
	    		total+=item.order_qty; 
			}
			for (var i = 0; i < itemArr.length; ++i) {
				console.log(itemArr[i]);
				itemArr[i].seq_no = fnGetNextSeqNo();
				AUIGrid.addRow(auiGrid, itemArr[i], 'last');
			}
		}
		
		// 행 추가, 삽입
		function fnAdd(list) {
			//  if ($M.getValue("cust_no") == "") {
			// 	alert("발주처를 선택해주세요.");
			// 	return false;
			// }
	    	if(fnCheckGridEmpty()) {
	    		if (list === undefined) {
					if ($M.getValue("cust_no") == "") {
						alert("발주처를 선택해주세요.");
						return false;
					}
	    			var item = new Object();
		    		item.part_no = "",
		    		item.part_name = "",
		    		item.unit_price = "0",
		    		item.current_stock = "0",
		    		item.total_price = "0",
		    		item.order_qty = "0",
		    		item.remark = "",
		    		item.check_qty = "0",
		    		item.approval_qty = "0",
		    		item.warehouse_cd_array = "";
		    		item.preorder_no_array = "";
		    		item.assign_center_name_str = "";
		    		item.assign_qty_array = "";
		    		item.assign = "";
		    		item.mi_qty = "0";
		    		item.last_in_dt = "";
		    		item.money_unit_cd = "";
		    		item.be0_out_total_qty = "0";
		    		item.be1_out_total_qty = "0";
		    		item.be2_out_total_qty = "0";
		    		item.delivary_dt = "";
		    		item.delivary_cnt = "0";
		    		item.part_name_change_yn = "N";
		    		item.preorder_inout_doc_no_str = "0";
		    		for (var i = 0; i < 10; ++i) {
		    			item.seq_no = fnGetNextSeqNo();
		    			AUIGrid.addRow(auiGrid, item, 'last');
		    		}
	    		} else {
	    			var itemArr = [];
	    			// 발주요청자료에서 입력
    				var result = [];
    				list.reduce(function(res, value) {
    				  if (!res[value.part_no]) {
    				    res[value.part_no] = { 
    				    	part_no: value.part_no,
    				    	part_name : value.part_name,
    				    	part_mng_name : value.part_mng_name,
    				    	unit_price : value.unit_price,
    				    	current_stock : value.current_stock,
    				    	total_price : value.total_price,
    				    	request_order_qty: 0, 
    				    	fixed_cnt : 0,
							special_price : value.special_price,
						};
    				    result.push(res[value.part_no])
    				  }
    				  //res[value.part_no].order_org_code = order_org_code;
    				  res[value.part_no].request_order_qty += value.request_order_qty;
    				  res[value.part_no].fixed_cnt += value.request_order_qty;
					  if(value.special_price != null && value.special_price != "0"){
						  res[value.part_no].unit_price = value.special_price;
					  }
    				  return res;
    				}, {});
    				console.log("reduce result => ", result);
    				var attrs = ['part_no', 'order_org_code'];
    				var temp = pivotList(list, attrs);
    				console.log("pivotList => ", temp);
    				// 선주문 시
    				var preAttrs = ['part_no', 'preorder_inout_doc_no'];
    				var preTemp = pivotList(list, preAttrs);
    				console.log("pivotList => 2222 ", preTemp);
		    		// 기존 합계 수량
    				var total = parseInt($M.getValue("total"));
	    			// 기존 합계금액
    				var total_amt = Number($M.getValue("total_amt"));
    				// console.log(result);
	    			for (var i = 0; i < result.length; ++i) {
	    				for (var j = 0; j < temp.length; ++j) {
	    					if (temp[j].label == result[i].part_no) {
	    						result[i]['detail'] = temp[j].groups;
	    					}
	    				}
	    				for (var j = 0; j < preTemp.length; ++j) {
	    					if (preTemp[j].label == result[i].part_no) {
	    						result[i]['preDetail'] = preTemp[j].groups;
	    					}
	    				}
	    				console.log("add groups on result => ", result);
	    				// 그리드에 add
	    				var item = new Object();
			    		item.part_no = result[i].part_no;
			    		item.part_name = result[i].part_name;
			    		item.unit_price = result[i].unit_price == null ? "0" : result[i].unit_price;
			    		item.current_stock = result[i].current_stock;
			    		item.part_mng_name = result[i].part_mng_name;
			    		// 발주요청자료 참조입력 시, 요청수량 밑으로 입력안되게
			    		item.fixed_cnt = result[i].fixed_cnt;
			    		var temp_total = Number(result[i].request_order_qty) * Number(result[i].unit_price);
			    		item.total_price = temp_total.toFixed(2);
			    		// 발주등록 시, 요청수량이 주문수량=심사수량=승인수량
			    		item.order_qty = result[i].request_order_qty;
			    		item.check_qty = result[i].request_order_qty;
			    		item.approval_qty = result[i].request_order_qty;
			    		
			    		item.mi_qty = result[i].mi_qty;
			    		item.last_in_dt = result[i].last_in_dt;
			    		item.money_unit_cd = result[i].money_unit_cd;
			    		console.log("result[i].be0_out_total_qty : ", result[i].be0_out_total_qty);
			    		console.log("result[i] : ", result[i]);
			    		item.be0_out_total_qty = result[i].be0_out_total_qty;
			    		item.be1_out_total_qty = result[i].be1_out_total_qty;
			    		item.be2_out_total_qty = result[i].be2_out_total_qty;
			    		item.part_name_change_yn = result[i].part_name_change_yn;
			    		
			    		// 계약납기일 일수(발주등록일에서 addDate해서 계약납기일을 구한다, ex: 90일이면, 발주일+90일이 날짜가 계약납기일)
			    		item.delivary_dt = $M.dateFormat($M.addDates($M.toDate($M.getValue("current")), $M.toNum(result[i].delivary_cnt)), 'yyyy-MM-dd');
			    		
			    		item.detail = result[i].detail;
			    		item.pre_detail = result[i].preDetail;
			    		console.log("result[i].preDetail : ", result[i].preDetail);
			    		// 자동 할당
			    		var center_cd_arr = [];
			    		var center_name_arr = [];
						var request_order_qty_arr = []; 
						var preorder_no_arr = [];
						var detail = result[i].detail;
						var remark_arr = [];
						var cust_arr = [];
						console.log("detail::::::::", detail);
						if (detail != null) {
							for (var k = 0; k < detail.length; ++k) {
								center_cd_arr.push(detail[k].label);
								var groups = detail[k].groups;
								var qty_sum = 0;
								for (var z = 0; z < groups.length; ++z) {
									console.log(groups[z]);
									// 센터 하나당 여러개의 부품할당요청번호 처리를 위해 |붙임
									preorder_no_arr.push(detail[k].label+"|"+groups[z].preorder_no);
									if (groups[z].request_order_qty == "" || groups[z].request_order_qty == 0) {
										alert("["+detail[k].label+"] 요청수량이 없거나, 0개 입니다.");
										itemArr.length = 0;
										return false;
									}
									qty_sum += groups[z].request_order_qty;
									if (groups[z].order_org_name == "") {
										alert("요청센터명이 없습니다.");
										itemArr.length = 0;
										return false;
									}
									if (!center_name_arr.includes(groups[z].order_org_name)) {
										center_name_arr.push(groups[z].order_org_name);										
									}
									if (groups[z].memo != "" && !remark_arr.includes(groups[z].memo)) {
										remark_arr.push(groups[z].memo)
									}
									if (groups[z].order_cust_name != "" && !cust_arr.includes(groups[z].order_cust_name)) {
										cust_arr.push(groups[z].order_cust_name)
									}
								}
								request_order_qty_arr.push(qty_sum);
							}
						}
						var preDetail = result[i].preDetail;
						var preorder_inout_doc_no_arr = [];
						console.log("preDetail::::::::", preDetail);
						console.log("preDetail.length::::::::", preDetail.length);
						if (preDetail != null) {
							for (var k = 0; k < preDetail.length; k++) {
								console.log("label : ::::", preDetail[k].label);
								preorder_inout_doc_no_arr.push(preDetail[k].label);
							}
						}
						var buttonText = "";
						var custText = "";
						var remarkText = "";
						var tempBtnName = center_name_arr;
						if (tempBtnName.length > 1) {
							var remain = tempBtnName.length-1;
							buttonText = tempBtnName[0] + " 외 "+remain;
						} else {
							buttonText = tempBtnName[0];
						}
						if (cust_arr.length > 1) {
							var remain = cust_arr.length-1;
							custText = cust_arr[0] + " 외 "+remain;
						} else {
							custText = cust_arr[0];
						}
						if (remark_arr.length > 1) {
							var remain = remark_arr.length-1;
							remarkText = remark_arr[0] + " 외 "+remain;
						} else {
							remarkText = remark_arr[0];
						}
						item.button_text = buttonText;
						custText = custText != undefined ? "/"+custText : "";
						remarkText = remarkText != undefined ? "/"+remarkText : "";
						item.remark = buttonText+custText+remarkText;
						item.preorder_no_str = $M.getArrStr(preorder_no_arr);
			    		item.warehouse_cd_array = $M.getArrStr(center_cd_arr, {sep : "^"});
			    		item.assign_center_name_str = $M.getArrStr(center_name_arr, {sep : "^"});
			    		item.assign_qty_array = $M.getArrStr(request_order_qty_arr, {sep : "^"});
						item.preorder_inout_doc_no_str = $M.getArrStr(preorder_inout_doc_no_arr, {sep : "^"});
			    		item.assign = "";
			    		// 최종 그리드에 담을 아이템
			    		itemArr.push(item);
						// 합계수량과 합계금액 갱신			    		
			    		total_amt+=Number(item.total_price);
			    		total+=item.order_qty; 
	    			}
	    			for (var i = 0; i < itemArr.length; ++i) {
	    				console.log(itemArr[i]);
	    				itemArr[i].seq_no = fnGetNextSeqNo();
	    				AUIGrid.addRow(auiGrid, itemArr[i], 'last');
	    			}
	    			
	    			$M.setValue("total", $M.setComma(total));
	    			$M.setValue("total_amt", $M.setComma(total_amt.toFixed(2)));
	    			
	    		}
	    		fnSetSelection();
	    	}
		}
		
		function pivotList(array, attrs) {
		    var output = [];
		    for (var i = 0; i < array.length; ++i) {
		        var ele = array[i];
		        var groups = output;
		        for (var j = 0; j < attrs.length; ++j) {
		            var attr = attrs[j];
		            var value = ele[attr];
		            var gs = groups.filter(function(g) {
		                return g.hasOwnProperty('label') && g['label'] == value;
		            });
		            if (gs.length == 0) {
		                var g = {};
		                g['label'] = value;
		                g['groups'] = [];
		                groups.push(g);
		                groups = g['groups'];
		            } else {
		                groups = gs[0]['groups'];
		            }
		        }
		        groups.push(ele);
		    }
		    return output;
		}
		
		function fnSetClientInfo(row) {
			console.log(row);
			// 고객 요청에 매입처랑 상관없이 발주넣기때문에 매입처 선택 시 초기화하는 로직 삭제함
			// 23.05.26 매입처에 따라 발주 단가가 변경되므로 매입처 선택 시 초기화하도록 수정
			//  AUIGrid.setGridData(auiGrid, []);
			// fnSetClearClientInfo(); 
			
			$M.setValue("cust_no", row.cust_no);
			$M.setValue("cust_name", row.cust_name);
			$M.setValue("cust_hp_no", fnGetHPNum(row.hp_no));
			$M.setValue("cust_tel_no", row.tel_no);
			$M.setValue("cust_fax_no", row.fax_no);
			$M.setValue("breg_name", row.breg_name); // 상호
			$M.setValue("breg_rep_name", row.breg_rep_name); // 대표자명
			$M.setValue("breg_no", row.breg_no);
			$M.setValue("breg_seq", row.breg_seq);
			$M.setValue("biz_post_no", row.post_no);
			$M.setValue("biz_addr1", row.addr1);
			$M.setValue("biz_addr2", row.addr2);
			$M.setValue("breg_cor_type", row.breg_cor_type); // 업태
			$M.setValue("breg_cor_part", row.breg_cor_part); // 업종
			$M.setValue("breg_seq", row.breg_seq);
		}
		
		function fnSetClearClientInfo() {
			$M.setValue("total", "0");
			$M.setValue("total_amt", "0");
			$M.setValue("cust_no", "");
			$M.setValue("cust_name", "");
			$M.setValue("cust_hp_no", "");
			$M.setValue("cust_tel_no", "");
			$M.setValue("cust_fax_no", "");
			$M.setValue("breg_name", ""); // 상호
			$M.setValue("breg_rep_name", ""); // 대표자명
			$M.setValue("breg_no", "");
			$M.setValue("breg_seq", "");
			$M.setValue("biz_post_no", "");
			$M.setValue("biz_addr1", "");
			$M.setValue("biz_addr2", "");
			$M.setValue("breg_cor_type", ""); // 업태
			$M.setValue("breg_cor_part", ""); // 업종
			$M.setValue("breg_seq", "");
		}
		
		// 상세정보
		function goBregDetailPopup() {
			var custNo = $M.getValue("cust_no");
			if (custNo == "") {
				alert("발주처를 선택하세요.");
				return false;
			} else if (fnCheckGridEmpty()){
				var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=730, left=0, top=0";
				var param = {
					"cust_no" : custNo
				};
				$M.goNextPage('/part/part0301p01', $M.toGetParam(param) ,{popupStatus : popupOption});
				//$M.goNextPage('/part/part0301p01' + '/' + param.cust_no, '', {popupStatus : popupOption});
			}
		}
		
		// 거래원장 조회
		function goTransactionHisPopup() {
			var custNo = $M.getValue("cust_no");
			if (custNo == "") {
				alert("발주처를 선택하세요.");
				return false;
			}
			var params = {
					's_cust_no' : $M.getValue("cust_no")
			};
			$M.goNextPage('/part/part0303p01', $M.toGetParam(params), {popupStatus : getPopupProp(1550, 860)});
		}
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return true;
			//return AUIGrid.validateGridData(auiGrid, ["part_no", "part_name","order_qty", "unit_price"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		// 발주요청참조자료 팝업
		function goOrderReferPopup() {
			//  if ($M.getValue("cust_no") == ""){
			// 	alert("발주처를 선택하세요.");
			// 	return false;
			// };
			if (fnCheckGridEmpty()) {
				var param = {
						/* 's_part_preorder_type_cd' : "1", // */
						/* 's_cust_no' : $M.getValue("cust_no"), */ 
						's_part_preorder_status_cd' : "0",
						'confirm_yn' : 'Y', // 23.02.28 정윤수 부품발주 부품추가 시 정상부품 아닌경우 confirm창 띄움
						's_cust_no' : $M.getValue("cust_no"), // 23.03.02 정윤수 매입처에 따라 단가를 조회하기 위하여 추가
				};
				openOrderRequestPartPanel('fnSearchReferPanel', $M.toGetParam(param));
			}
		}
		
		function fnSearchReferPanel(list) {
			console.log(list);
			for (var i = 0; i < list.length; ++i) {
				 var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", list[i].part_no);
				 if (rowItems.length != 0){
					 console.log(rowItems, list[i].part_no);
					 alert("부품번호가 중복됩니다.\n"+list[i].part_no);
					 return false;					 
				 }
			}
			fnAdd(list);
		} 
		
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "_$uid",
					width : "100%",
					editable : true,
					showStateColumn : true,
					showRowNumColumn: true,
					enableSorting : true,
					/* fillColumnSizeMode : false, */
					// fixedColumnCount : 11,
					editableOnFixedCell : true,
					onlyEnterKeyEditEnd : true // 엔터로 옆으로 이동하는것 방지
				};
				var columnLayout = [
					{
						dataField : "_$uid", 
						visible : false
					},
					{
						dataField : "fixed_cnt", // 센터요청수량-부품요청자료(이 이하로 입력안되야함)
						visible : false
					},
					{
						dataField : "preorder_no_array", // 부품발주요청 번호(저장할때)
						visible : false
					},
					{
						dataField : "preorder_no_str", // 부품발주요청 번호(가공전)
						visible : false
					},
					{
						dataField : "warehouse_cd_array", // 센터요청수량-부품할당 후 결과
						visible : false
					},
					{
						dataField : "assign_center_name_str", // 할당 센터 이름
						visible : false
					},
					{
						dataField : "assign_qty_array", // 할당된 수량
						visible : false
					},
					{
						dataField : "assign_str", // 서버로 보내져서 저장되는 센터 할당 정보
						visible : false
					},
					{
						dataField : "seq_no", // 순번
						visible : false
					},
					{
						dataField : "preorder_inout_doc_no_str", // 선주문 전표번호 
						visible : false
					},
					{
						dataField : "special_price", // special단가 
						visible : false
					},
					{ 
						headerText : "부품번호", 
						dataField : "part_no", 
						style : "aui-editable",
						width : "10%",
						editRenderer : {
							type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
							conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
								var param = {
										's_search_kind' : 'DEFAULT_PART',
										/* 's_warehouse_cd' : "${SecureUser.org_code}", */
										's_only_warehouse_yn' : "N",
										/* 's_not_sale_yn' : "Y",		// 매출정지 제외
						    			's_not_in_yn' : "Y",			// 미수입 제외 */
						    			//'s_part_mng_cd' : "1"
										's_deal_cust_no' : $M.getValue("cust_no"), // 23.03.02 정윤수 매입처에 맞는 단가 조회하도록 추가
								};
								return fnGetPartSearchRenderer(dataField, param);
							},
						}
					},
					{ 
						headerText : "부품명", 
						dataField : "part_name", 
						style : "aui-left",
						editable : true,
						width : "10%",
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "-" : value;
						},
					},
					{ 
						headerText : "관리구분", 
						dataField : "part_mng_name", 
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "-" : value;
						},
					},
					{ 
						headerText : "입고예정일", 
						dataField : "in_plan_dt", 
						dataType : "date",   
						width : "10%",
						style : "aui-center aui-editable",
						dataInputString : "yyyymmdd",
						formatString : "yyyy-mm-dd",
						editRenderer : {
							  type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
							  defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
							  onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
							  maxlength : 8,
							  onlyNumeric : true, // 숫자만
							  validator : AUIGrid.commonValidator
						},
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							// 라벨펑션사용 시, yyyy-mm-dd로 안만들어져서 강제로 만듬
				            return value == "" || value == null ? "-" : value.substring(0, 4) + "-" + value.substring(4, 6) + "-" + value.substring(6, 8);
						},
						editable : true
					},
					{ 
						headerText : "현재고", 
						dataField : "current_stock",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right aui-popup",
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "0" : $M.setComma(value);
						},
					},
					{ 
						headerText : "발주중", 
						dataField : "in_order", 
						style : "aui-right",
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "0" : $M.setComma(value);
						},
					},
					{ 
						headerText : "작성", 
						dataField : "order_qty", 
						style : "aui-editable",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right aui-editable",
						editable : true,
						editRenderer : {
						    type : "InputEditRenderer",
						    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
						    allowPoint : false // 소수점(.) 입력 가능 설정
						},
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "0" : $M.setComma(value);
						},
					},
					{ 
						headerText : "심사", 
						dataField : "check_qty",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right",
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "0" : $M.setComma(value);
						},
					},
					{ 
						headerText : "승인", 
						dataField : "approval_qty", 
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right",
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "0" : $M.setComma(value);
						},
					},
					{ 
						headerText : "W", 
						dataField : "money_unit_cd", 
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "-" : value;
						},
					},
					{ 
						headerText : "단가", 
						dataField : "unit_price",
						dataType : "numeric",
						formatString : "#,##0.00",
						style : "aui-editable aui-right",
						editable : true,
						editRenderer : {
						    type : "InputEditRenderer",
						    onlyNumeric : true,
						    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
						    allowPoint : true // 소수점(.) 입력 가능 설정
						},
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "-" : $M.setComma(value);
						},
					},
					{ 
						headerText : "금액", 
						dataField : "total_price", 
						dataType : "numeric",
						formatString : "#,##0.00",
						style : "aui-editable aui-right",
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							if (value != null && value != "") {
								return $M.setComma(value.toFixed(2));
							} else {
								return "-";
							}
						},
					},
					{ 
						headerText : "당해", 
						dataType : "numeric",
						dataField : "be0_out_total_qty", 
						editable : false,
						style : "aui-right aui-popup",
					},
					{ 
						headerText : "전년", 
						dataType : "numeric",
						dataField : "be1_out_total_qty", 
						editable : false,
						style : "aui-right aui-popup",
					},
					{ 
						headerText : "전전년", 
						dataType : "numeric",
						dataField : "be2_out_total_qty", 
						editable : false,
						style : "aui-right aui-popup",
					},
					{ 
						headerText : "적요", 
						dataField : "remark", 
						style : "aui-editable",
						width : "10%",
						editable : true,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "-" : value;
						},
					},
					{ 
						headerText : "최종입고", 
						dataField : "last_in_dt", 
						formatString : "yyyy-mm-dd",
						dataType : "date", 
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							// 라벨펑션사용 시, yyyy-mm-dd로 안만들어져서 강제로 만듬
				            return value == "" || value == null ? "-" : value.substring(0, 4) + "-" + value.substring(4, 6) + "-" + value.substring(6, 8);
						},
					},
					{ 
						headerText : "계약납기일", 
						dataField : "delivary_dt", 
						dataType : "date",  
						width : "10%",
						style : "aui-center aui-editable",
						dataInputString : "yyyymmdd",
						formatString : "yyyy-mm-dd",
						editRenderer : {
							  type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
							  defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
							  onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
							  maxlength : 8,
							  onlyNumeric : true, // 숫자만
							  validator : AUIGrid.commonValidator
						},
						editable : true
					},
					{ 
						headerText : "미입고", 
						dataField : "mi_qty", 
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right",
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "0" : $M.setComma(value);
						},
						editable : false
					},
					{
						headerText : "센터할당",
						dataField : "button_text",
						width : "8%",
						renderer : {
							type : "ButtonRenderer",
							onClick : function(event) {
								goAssignPopup(event);
							},
						},
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				            return value == "" || value == null ? "할당" : value;
						},
						style : "aui-center",
						editable : false
					},
					{
						headerText : "기매출단가",
						dataField : "기매출단가",
						width : "8%",
						renderer : {
							type : "ButtonRenderer",
							onClick : function(event) {
								if (event.item.part_no == "") {
									return alert("부품을 선택하세요");
								}
								var params = {
										"s_cust_no" : $M.getValue("cust_no"),
										"s_item_id" : event.item.part_no
								};
								var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=400, left=0, top=0";
								$M.goNextPage("/part/part0302p03", $M.toGetParam(params), {popupStatus : poppupOption});
							},
						},
						labelFunction : function(rowIndex, columnIndex, value,
								headerText, item) {
							
							return '조회'
						},
						style : "aui-center",
						editable : false
					},
					{
						headerText : "삭제",
						dataField : "removeBtn",
						width : "8%",
						renderer : {
							type : "ButtonRenderer",
							onClick : function(event) {
								var isRemoved = AUIGrid.isRemovedById(auiGrid);
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);		
								} else {
									AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
								}
							},
						},
						labelFunction : function(rowIndex, columnIndex, value,
								headerText, item) {
							return '삭제'
						},
						style : "aui-center",
						editable : false
					},
					{
						dataField : "part_name_change_yn",
						visible : false
					}
				];
				// 실제로 #grid_wrap 에 그리드 생성
				auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
				// 그리드 갱신
				AUIGrid.setGridData(auiGrid, []);
				// 추가행 에디팅 진입 허용
				AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
					if (event.dataField == "part_name") {
						var changeYn = event.item.part_name_change_yn;
						if (changeYn == "Y") {
							return true;	 
						} else {
							return false;
						}
					}
				});
				// 에디팅 정상 종료 이벤트 바인딩
				AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
				// 에디팅 정상 종료 이벤트 바인딩
				AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
				// 에디팅 취소 이벤트 바인딩
				AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);
				AUIGrid.bind(auiGrid, "addRow", function( event ) {
					fnUpdateCnt();
				});
				AUIGrid.bind(auiGrid, "removeRow", function( event ) {
					fnUpdateCnt();
				});
				AUIGrid.bind(auiGrid, "updateRow", function( event ) {
					var total = AUIGrid.getColumnValues(auiGrid, "total_price");
					var result = total.reduce(function(a, b) { return $M.toNum(a) + $M.toNum(b); }, 0);
					var totalAmt = result.toFixed(2);
					if (totalAmt == "0.00") {totalAmt = "0"};
					$M.setValue("total_amt", $M.setComma(totalAmt));
				});
				AUIGrid.bind(auiGrid, "cellClick", function(event) {
					if (event.item.part_no == "") {
						return false;
					};
					if(event.dataField == "be0_out_total_qty" || event.dataField == "be1_out_total_qty" || event.dataField == "be2_out_total_qty") {
						var param = {
							part_no : event.item.part_no
						}
						if (event.dataField == "be0_out_total_qty") {
							var d = new Date();
							var pastYear = d.getFullYear();
							param["s_start_dt"] = pastYear+"0101";
							param["s_end_dt"] = pastYear+"1231";
						}
						if (event.dataField == "be1_out_total_qty") {
							var d = new Date();
							var pastYear = d.getFullYear()-1;
							param["s_start_dt"] = pastYear+"0101";
							param["s_end_dt"] = pastYear+"1231";
						}
						if (event.dataField == "be2_out_total_qty") {
							var d = new Date();
							var pastYear = d.getFullYear()-2;
							param["s_start_dt"] = pastYear+"0101";
							param["s_end_dt"] = pastYear+"1231"; 
						}
						var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=450, left=0, top=0";
						$M.goNextPage('/part/part0403p02', $M.toGetParam(param), {popupStatus : poppupOption});
					} else if (event.dataField == 'current_stock') {
						var param = {
							part_no : event.item.part_no
						}
						var popupOption1 = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1050, height=650, left=0, top=0";
						$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption1});
					}
				});
				AUIGrid.resize(auiGrid);
		}
		
		// 센터할당
		function goAssignPopup(event) {
			if (event.item.part_name == "") {
				AUIGrid.setSelectionByIndex(auiGrid, event.rowIndex, 9);
				alert("부품번호를 먼저 입력하세요.");
				return false;
			}
			if (event.item.order_qty == "0" || event.item.order_qty == "") {
				AUIGrid.setSelectionByIndex(auiGrid, event.rowIndex, 15);
				alert("작성 개수가 0개입니다.");
				return false;
			}
			console.log(event);
			var center_cd_arr = [];
			var request_order_qty_arr = []; 
			var preorder_no_arr = [];
			var detail = event.item.detail;
			if (detail != null) {
				for (var i = 0; i < detail.length; ++i) {
					center_cd_arr.push(detail[i].label);
					var groups = detail[i].groups;
					var qty_sum = 0;
					for (var j = 0; j < groups.length; ++j) {
						// 센터 하나당 여러개의 부품할당요청번호 처리를 위해 |붙임
						preorder_no_arr.push(detail[i].label+"|"+groups[j].preorder_no);
						qty_sum += groups[j].request_order_qty;
					}
					request_order_qty_arr.push(qty_sum);
				}
			}
			
			console.log("==>");
			console.log(event.item);
			var preorder_no_str = $M.getArrStr(preorder_no_arr);
			var center_cd_str = $M.getArrStr(center_cd_arr, {sep : "^"});
			var init_center_cd_str = $M.getArrStr(center_cd_arr, {sep : "^"});
			var request_order_qty_str = $M.getArrStr(request_order_qty_arr, {sep : "^"});
			var init_request_order_qty_str = $M.getArrStr(request_order_qty_arr, {sep : "^"});
			
			if (event.item.warehouse_cd_array != ""){
				center_cd_str = event.item.warehouse_cd_array;
				request_order_qty_str = event.item.assign_qty_array;
			}
			
			var param = {
				uid : event.item._$uid,
				seq_no : event.item.seq_no,	
				parent_js_name : "fnSetAssginResult",
				part_no : event.item.part_no,
				part_name : event.item.part_name,
				order_qty : event.item.order_qty,
				center_cd_str : center_cd_str,
				init_center_cd_str : init_center_cd_str, // 초기화 버튼용
				request_order_qty_str : request_order_qty_str,
				init_request_order_qty_str : init_request_order_qty_str, // 초기화 버튼용
				preorder_no_str : preorder_no_str,
				part_order_status_cd : "${bean.part_order_status_cd}"
			}
			console.log(param);
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=470, height=500, left=0, top=0";
			$M.goNextPage('/part/part0403p03', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		function fnUpdateCnt() {
			var cnt = AUIGrid.getGridData(auiGrid).length;
			$("#total_cnt").html(cnt);
			// 행 갯수가 변경됬을 경우 합계와 수량 다시 계산
			var totalAmtTemp = AUIGrid.getColumnValues(auiGrid, "total_price");
			var result = totalAmtTemp.reduce(function(a, b) { return a + b; }, 0);
			var totalAmt = result.toFixed(2);
			if (totalAmt == "0.00") {totalAmt = "0"};
			$M.setValue("total_amt", $M.setComma(totalAmt));
			
			var cnt = AUIGrid.getColumnValues(auiGrid, "order_qty");
			var cntResult = cnt.reduce(function(a, b) { return a + b; }, 0);
			$M.setValue("total", $M.setComma(cntResult));
		}
		
		// 할당 후
		function fnSetAssginResult(row) {
			console.log(row);
			AUIGrid.updateRow(auiGrid, 
					{ 
					  "warehouse_cd_array" : row.org_cd_str,
					  "assign_center_name_str" : row.org_name_str,
					  "button_text" : row.button_text,
					  "preorder_no_str" : row.assign_preorder_str,
					  "assign_qty_array" : row.assign_qty_array,
					  "fixed_cnt" : row.fixed_cnt
					}
			, AUIGrid.rowIdToIndex(auiGrid, row.uid));
		}
		
		// 편집 핸들러
		function auiCellEditHandler(event) {
			switch(event.type) {
			case "cellEditEndBefore" :
				if(event.dataField == "order_qty") {
					if(event.item.preorder_inout_doc_no_str != 0) {
						alert("선주문수량이 포함되어있으므로, 수정 시 참고하세요.");
					}
				
					if (event.value < event.item.fixed_cnt){
						AUIGrid.updateRow(auiGrid, {
							fixed_cnt : event.value,
						}, event.rowIndex);
						/* setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "발주 요청한 개수("+event.item.fixed_cnt+") 미만으로 지정할 수 없습니다.");
						}, 1);
						return event.oldValue; */
					} 
				}
				if(event.dataField == "part_no") {
					console.log(event);
					var isUnique = AUIGrid.isUniqueValue(auiGrid, event.dataField, event.value);	
					if (isUnique == false && event.value != "" && event.value != event.item.part_no) {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
						}, 1);
						return event.oldValue;
					} else {
						if (event.value == "") {
							return event.oldValue;							
						}
					}
				}
				if (event.dataField == "unit_price") {
					if (event.value != ""){
						return event.value.toFixed(2);						
					}
				}
				if (event.dataField == "total_price") {
					if (event.value != ""){
						return event.value.toFixed(2);						
					}
				}
				break;
			case "cellEditEnd" :
				if(event.dataField == "part_no") {
					if (event.value == ""){
						return "";
					}
					// remote renderer 에서 선택한 값
					var item = fnGetPartItem(event.value);
					console.log("remote renderer ==> ", item);
					//console.log(item);
					console.log($M.getValue("current"));
					if(item.part_mng_cd != "1"){
						if(confirm("정상재고가 아닌 부품이 선택되었습니다. ("+item.part_no+")\n추가 하시겠습니까?") == false){
							event.value = "";
							return ;
						}
					}
					if(item === undefined) {
						AUIGrid.updateRow(auiGrid, {part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						AUIGrid.updateRow(auiGrid, {
							fixed_cnt : "",
							preorder_no_array : "",
							warehouse_cd_array : "",
							assign_center_name_str : "",
							preorder_inout_doc_no_str : "0",
							assign_qty_array : "",
							assign_str : "",
							part_name : item.part_name,
							maker_cd_name : item.maker_cd_name,
							part_production_cd_name : item.part_production_cd_name,
							part_mng_name : item.part_mng_name,
							part_group_cd_name : item.part_group_cd_name,
							// unit_price : item.unit_price,
							unit_price : item.special_price > 0 ? item.special_price:item.unit_price, // 24.01.04 Q&A 20148 special 단가 있으면 대체하도록 추가
							special_price : item.special_price, 
							money_unit_cd : item.money_unit_cd,
							mi_qty : item.mi_qty,
							last_in_dt : item.last_in_dt,
							be0_out_total_qty : item.be0_out_total_qty,
							be1_out_total_qty : item.be1_out_total_qty,
							be2_out_total_qty : item.be2_out_total_qty,
							// 계약납기일 일수(발주등록일에서 addDate해서 계약납기일을 구한다, ex: 90일이면, 발주일+90일이 날짜가 계약납기일)
				    		delivary_dt : $M.dateFormat($M.addDates($M.toDate($M.getValue("current")), $M.toNum(item.delivary_cnt)), 'yyyy-MM-dd'),
							current_stock : item.current_stock,
							part_name_change_yn : item.part_name_change_yn,
							order_qty : "",
							check_qty : "",
							approval_qty : "",
							total_price : 0,
							button_text : ""
						}, event.rowIndex);
					}
				} else if (event.dataField == "order_qty") {
					AUIGrid.updateRow(auiGrid, {
						check_qty : event.value,
						approval_qty : event.value,
						total_price : event.value * event.item.unit_price
					}, event.rowIndex);
					var orderQty = AUIGrid.getColumnValues(auiGrid, event.dataField);
					var result = orderQty.reduce(function(a, b) { return $M.toNum(a) + $M.toNum(b); }, 0);
					$M.setValue("total", $M.setComma(result));
				} else if (event.dataField == "unit_price") {
					AUIGrid.updateRow(auiGrid, {total_price : event.value * event.item.order_qty}, event.rowIndex);
				} 
				break;
			}
		};
		
		// part_no 으로 검색해온 정보 아이템(row) 반환 (엔터 or 마우스 클릭시 호출).
		function fnGetPartItem(part_no) {
			var item;
			$.each(recentPartList, function(index, row) {
				if(row.part_no == part_no) {
					item = row;
					return false; // 중지
				}
			});
			return item;
		};

		// 체크
		function fnValidation() {
			var Data = AUIGrid.getGridData(auiGrid);

			var GridData = [];

			for(var i=0; i<Data.length; i++){
				if(Data[i].part_no != ""){
					GridData.push(Data[i]);
				}
			}
			for(var j = 0; j < GridData.length; j++) {
				if(GridData[j].order_qty == 0) {
					alert("작성 수량은 0보다 커야합니다.");
					return false;
				}
			}
		}
		// 저장
		function goSave(isRequestAppr) {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("발주할 부품이 없습니다.");
				return false;
			};
			if(fnCheckGridEmpty(auiGrid) === false) {
				return false;
			};
			
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}
			if(fnValidation() === false) { // 작성수량 체크
				return false;
			}
			// part_no없는 빈 값 삭제
			var tList = AUIGrid.getGridData(auiGrid);
			console.log(tList);
			var removeRowIds = []; 
			for (var i = tList.length-1; i >= 0; --i) {
				if (tList[i].part_no == undefined || tList[i].part_no == "") {
					removeRowIds.push(tList[i]._$uid);
				}
			}
			AUIGrid.removeRowByRowId(auiGrid, removeRowIds);
			
			if (AUIGrid.validateGridData(auiGrid, ["part_no", "part_name","order_qty", "unit_price"], "필수 항목은 반드시 값을 입력해야합니다.") == false) {
				return false;
			}

			// 서버로 올리기 위해 센터할당 가공
			var tempGrid = AUIGrid.getAddedRowItems(auiGrid);
			console.log(tempGrid);
			for (var i = 0; i < tempGrid.length; ++i) {
				var cd_temp = tempGrid[i].warehouse_cd_array;
				var preorder_no_array_temp = []; // | 로 묶일 preorder_no
				var map = new Object(); // key : 센터 코드, value : preorder_no
				var preorder_temp = tempGrid[i].preorder_no_str;
				console.log(preorder_temp);
				if (preorder_temp != null && preorder_temp != "") {
					var value = preorder_temp.split("#");
					console.log("str", value);
					for (var j = 0; j < value.length; ++j) {
						var temp = value[j].split("|");
						var key = temp.shift();
						if (!map.hasOwnProperty(key)){
							map[key] = temp;
						} else {
							map[key].push(temp);
						}
					}
				}
				if (cd_temp != "") {
					cd_temp = cd_temp.split("^");
					for (var k = 0; k < cd_temp.length; ++k) {
						var isAssginCenter = map[cd_temp[k]];
						console.log(isAssginCenter);
						if (isAssginCenter != null) {
							var sep = isAssginCenter.join("|");
							preorder_no_array_temp.push(sep);
						} else {
							preorder_no_array_temp.push("0");
						}
					}
				}
				// 저장하기 전, seq_no 정리
				AUIGrid.updateRow(auiGrid, { "seq_no" : i+1}, AUIGrid.rowIdToIndex(auiGrid, tempGrid[i]._$uid));
				AUIGrid.updateRow(auiGrid, { "preorder_no_array" : preorder_no_array_temp.join("^") }, AUIGrid.rowIdToIndex(auiGrid, tempGrid[i]._$uid));
			}
			
			frm = $M.toValueForm(frm);
			var gridForm = fnChangeGridDataToForm(auiGrid);
			
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);
			
			console.log("save ==> ", gridForm);
			
			if (isRequestAppr != undefined){
				$M.setValue("save_mode", "appr"); // 결재요청
				if(confirm("결재 후 수정 및 삭제가 제한됩니다.\n계속 진행하시겠습니까?") == false){
					return false;
				}
			} else {
				$M.setValue("save_mode", "save"); //저장
				if(confirm("저장하시겠습니까?") == false){
					return false;
				}
			}
			
			$M.goNextPageAjax(this_page+"/save", gridForm, {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("저장이 완료되었습니다.");
		    			var param = {
							part_order_no : result.part_order_no
						};
						var poppupOption = "";
						$M.goNextPage('/part/part0403p01', $M.toGetParam(param));
					}
				}
			);
		}
		
		function goRequestApproval() {
			goSave('requestAppr');
		}
		
		// 매입처조회 팝업
		function fnSearchClientComm() {
			var param = {
					"order_yn" : "Y"
			};
			openSearchClientPanel('fnSetClientInfo', 'comm', $M.toGetParam(param));
		}
		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "부품발주목록", exportProps);
		}
		

		 // 부품대량입력 팝업
	    function fnMassInputPart() {
			var custNo = $M.getValue("cust_no");
			if (custNo == "") {
				alert("발주처를 선택하세요.");
				return false;
			}
			var popupOption = "";
			var param = {
  				"parent_js_name" : "fnSetInputPart",
				'confirm_yn' : "Y", // 23.02.28 정윤수 부품발주 부품추가 시 정상부품 아닌경우 confirm창 띄움
				"cust_no" : $M.getValue("cust_no"),
  			};
  		
			$M.goNextPage('/cust/cust0201p06', $M.toGetParam(param), {popupStatus : popupOption});
	    	
	    }
		 
	    // 부품대량입력 데이터 세팅
	    function fnSetInputPart(list) {
	    	for(var i = 0; i < list.length; i++) {
		    	var item = list[i];
				var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", item.part_no);
				if (rowItems.length == 0) {
		    		item["seq_no"] = fnGetNextSeqNo();
					item["be0_out_total_qty"] = item.be0_out_total_qty;
					item["be1_out_total_qty"] = item.be1_out_total_qty;
					item["be2_out_total_qty"] = item.be2_out_total_qty;
					item["fixed_cnt"] = "";
					item["preorder_no_array"] = "";
					item["warehouse_cd_array"] = "";
					item["assign_center_name_str"] = "";
					item["assign_qty_array"] = "";
					item["assign_str"] = "";
					item["remark"] = "";
					item["order_qty"] = item.qty;
					item["check_qty"] = item.qty;
					item["approval_qty"] = item.qty;
					// item["unit_price"] = item.order_price;
					item["unit_price"] = item.special_price > 0 ? item.special_price : item.order_price; // 24.01.04 special 단가가 있으면 order_price 대체하도록 수정
					item["special_price"] = item.special_price;
					// item["total_price"] = item.qty * item.order_price;  // 21.08.02 (SR:12074) 수정 - 황빛찬
					item["total_price"] = item.special_price > 0 ? item.qty * item.special_price : item.qty * item.order_price;  // 24.01.04 special 단가가 있으면 order_price 대체하도록 수정
					item["current_stock"] = item.current_qty;	// 전체현재고
					item["preorder_inout_doc_no_str"] = "0";
					// 계약납기일 일수(발주등록일에서 addDate해서 계약납기일을 구한다, ex: 90일이면, 발주일+90일이 날짜가 계약납기일)
		    		item["delivary_dt"] = $M.dateFormat($M.addDates($M.toDate($M.getValue("current")), $M.toNum(item.delivary_cnt)), 'yyyy-MM-dd');
					AUIGrid.addRow(auiGrid, item, 'last');
	    		}
	   		}
	    }
		function fnCustCheck() {
			var custNo = $M.getValue("cust_no");

			if(custNo == "" || custNo == undefined){
				alert("선택된 발주처 정보가 없습니다.");
				return;
			}

		}
		
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
			<div class="content-box" style="border: none;">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left approval-left" style="align-items: center;">
						<div class="left">
							<!-- <button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button> -->
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"></jsp:include>
							<div style="min-width:80px; margin-top: auto; margin-bottom: auto; margin-right: 10px;">
								<span class="condition-item">상태 : ${apprBean.appr_proc_status_name}</span>
							</div>
						</div>
					</div>
					<!-- 결재영역 -->
					<div class="p10"> 
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
					<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->
					<div class="row">
<!-- 좌측 폼테이블-->
						<div class="col-6">
							<div>
								<table class="table-border">
									<colgroup>
										<col width="100px">
										<col width="">
										<col width="100px">
										<col width="">
									</colgroup>
									<tbody>
										<tr>
											<th class="text-right">발주번호</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width120px" style="padding-right: 0;">
														<input type="text" class="form-control" readonly="readonly" id="part_order_no1"> <!-- 페이지 접속할때의 현재 날짜 -->
													</div>
												</div>
											</td>
											<th class="text-right">담당자</th>
											<td>
												<input type="text" class="form-control width120px" readonly="readonly" value="${SecureUser.user_name}">
											</td>
										</tr>
										<tr>
											<th class="text-right rs">발주처(매입처)</th>
											<td>
												<div class="input-group width120px">
													<input type="text" class="form-control border-right-0 width120px" readonly="readonly" id="cust_name" name="cust_name" required="required" alt="발주처">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
												</div>
											</td>
											<th class="text-right">휴대폰</th>
											<td>
												<!-- readonly라 format 체크안함(데이터가 이상하면 아예 기능안함) -->
												<input type="text" class="form-control width140px" readonly="readonly" id="cust_hp_no" name="cust_hp_no" alt="휴대폰">
											</td>
										</tr>
										<tr>
											<th class="text-right">발주등록일</th>
											<td>
												<div class="input-group width120px">
													<input type="text" class="form-control border-right-0" dateFormat="yyyy-MM-dd" alt="발주등록일" disabled="disabled" id="current" name="current" value="${inputParam.s_current_dt}"> <!- 발주등록일 수정못하게 변경 -->
													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button>
												</div>
											</td>
											<th class="text-right">발주처리일</th>
											<td>
												<input type="text" class="form-control width120px" readonly="readonly" alt="발주처리일">
											</td>
										</tr>
										<tr>
											<th class="text-right">합계수량</th>
											<td>
												<input type="text" class="form-control text-right width120px" readonly="readonly" id="total" name="total" value="0" alt="합계수량" min="1" alt="합계수량">
											</td>
											<th class="text-right">합계금액</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width120px">
														<input type="text" class="form-control text-right width120px" readonly="readonly" id="total_amt" name="total_amt" value="0" alt="합계금액" required="required" format="decimal">
													</div>
													<div class="col-1">원</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">발주조건(외부용)</th>
											<td colspan="3">
												<textarea class="form-control" style="height: 50px; resize: none;" id="order_condition" name="order_condition" alt="발주조건(외부용)" maxlength="4000"></textarea>
											</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
<!-- 좌측 폼테이블-->		
<!-- 우측 폼테이블-->
						<div class="col-6">
							<div>
								<table class="table-border">
									<colgroup>
										<col width="70px">
										<col width="">
										<col width="70px">
										<col width="">
									</colgroup>
									<tbody>
										<tr>
											<th class="text-right">업체명</th>
											<td colspan="3">
												<div class="form-row inline-pd widthfix">
													<div class="col width120px">
														<input type="text" class="form-control text-left width120px" readonly="readonly" id="breg_name" name="breg_name" alt="업체명">
													</div>
													<div class="col width60px">
														<button type="button" class="btn btn-primary-gra width60px" onclick="javascript:goBregDetailPopup()">상세정보</button>
													</div>
													<div class="col width90px" style="padding-left: 5px">
														<button type="button" class="btn btn-primary-gra width90px" onclick="javascript:goTransactionHisPopup()">거래원장조회</button>
													</div>
												</div>
											</td>			
										</tr>
										<tr>
											<th class="text-right">대표자</th>
											<td>
												<input type="text" class="form-control width120px" readonly="readonly" id="breg_rep_name" name="breg_rep_name" alt="대표자">
											</td>
											<th class="text-right">전화번호</th>
											<td>
												<input type="text" class="form-control width140px" readonly="readonly" id="cust_tel_no" name="cust_tel_no" alt="전화번호">
											</td>
										</tr>
										<tr>
											<th class="text-right">사업자No</th>
											<td>
												<input type="text" class="form-control width140px" readonly="readonly" id="breg_no" name="breg_no" alt="사업자번호">
											</td>
											<th class="text-right">팩스번호</th>
											<td>
												<input type="text" class="form-control width140px" readonly="readonly" id="cust_fax_no" name="cust_fax_no" alt="팩스번호">
											</td>
										</tr>
										<tr>
											<th class="text-right">적요</th>
											<td colspan="3">
												<input type="text" class="form-control" id="desc_text" name="desc_text" maxlength="200" alt="적요">
											</td>
										</tr>
										<tr>
											<th class="text-right">특이사항(내부용)</th>
											<td colspan="3">
												<textarea class="form-control" style="height: 50px; resize: none;" id="special_text" name="special_text" maxlength="4000" alt="특이사항(내부용)"></textarea>
											</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
<!-- 우측 폼테이블-->				
					</div>
<!-- /폼테이블 -->
<!-- 하단 폼테이블 -->				
					<div>
<!-- 부품내역 -->
						<div class="title-wrap mt10">
							<h4>발주부품목록</h4>
							<div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>					
							</div>
						</div>						
						<div id="auiGrid" style="margin-top: 5px; height: 280px;"></div>
<!-- /부품내역 -->
					</div>
<!-- /하단 폼테이블 -->	
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
			<%-- <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	 --%>	
		</div>
<!-- /contents 전체 영역 -->	
</div>
<input type="hidden" id="cust_no" name="cust_no" required="required">
<input type="hidden" id="breg_seq" name="breg_seq">
<input type="hidden" id="use_yn" name="use_yn" value="Y">
<input type="hidden" id="part_order_status_cd" name="part_order_status_cd" value="0">
<input type="hidden" id="save_mode" name="save_mode"> <!-- appr(결재요청 후 저장), save(저장) -->		
<input type="hidden" id="machine_ship_plan_seq" name="machine_ship_plan_seq"> <!-- 어테치발주로 인해 선적일정번호 세팅 -->		

</form>
</body>
</html>