<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > Stock의뢰서등록 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	    var auiGrid_part;
	    var auiGrid_option;
	    var auiGrid_memo;

		var parentPaidList; // 유상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)
		var parentFreeList; // 무상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)

		var isMachine = false;

		var centerAddr;

		$(document).ready(function() {
			createAUIGrid();
			fnSetInit();
		});

		function fnChangeOutOrgCode() {
			var cd = $M.getValue("out_org_code");
			if (cd != "") {
				$M.setValue("out_post_no", centerAddr[cd][0]);
				$M.setValue("out_addr1", centerAddr[cd][1]);
			} else {
				$M.setValue("out_post_no", "");
				$M.setValue("out_addr1", "");
			}
			$M.setValue("receive_plan_ti_1", "00");
			$M.setValue("receive_plan_ti_2", "00");
			$M.setValue("receive_plan_ti_temp", "00시 00분");
		}

		function fnSetInit() {
			$(".process2 :input").attr("disabled", true);
			centerAddr = new Object();
			var firstCd = "";
			<c:forEach items="${outOrgCodeList}" var="item" varStatus="status">
				if ("${item.org_code}" != "") {
					<c:if test="${status.first}">firstCd = "${item.org_code}"</c:if>
					centerAddr["${item.org_code}"] = ["${item.post_no}", "${item.addr1}"];
				}
			</c:forEach>
			$M.setValue("out_post_no", centerAddr[firstCd][0]);
			$M.setValue("out_addr1", centerAddr[firstCd][1]);
		}

		function goAddPartPopup() {
			if ($M.getValue("machine_name") == "") {
				alert("모델명을 입력해주세요.");
				$("#machine_name").focus();
				return false;
			}
			parentFreeList = [];
    		parentPaidList = [];
    		var tempList = AUIGrid.exportToObject(auiGrid_part);
    		for (var i = 0; i < tempList.length; i++) {
    			var obj = new Object();
    			for (var prop in tempList[i]) {
    				obj[prop.substring(5,prop.length)] = tempList[i][prop];
    			}
    			if (obj['attach_yn'] != 'Y') {
    				if (obj['free_yn'] === 'Y') {
    					parentFreeList.push(obj);
    				} else {
    					parentPaidList.push(obj);
    				}
    			}
    		}
    		var param = {
        			cost_part_breg_no : $M.getValue("breg_no"), // 사업자번호
        			machine_plant_seq : $M.getValue("machine_plant_seq"),
        			page_type : "OUT"
        	}
        	openFreeAndPaidMachinePart('fnSetFreeAndPaidMachinePart', $M.toGetParam(param));
		}

        function fnSetFreeAndPaidMachinePart(list) {
        	var row = $.extend(true, [], list);

        	for (var i = 0; i < row.parentPaidList.length; ++i) {
 	        	row.parentPaidList[i]['paid_free_yn'] = "N";
 	        	row.parentPaidList[i]['paid_attach_yn'] = "N";
 	        	row.parentPaidList[i]['paid_default_qty'] = row.parentPaidList[i].paid_default_qty == null ? 0 : row.parentPaidList[i]['paid_default_qty'];
 	        	row.parentPaidList[i]['paid_add_qty'] = row.parentPaidList[i].paid_add_qty == null ? 0 : row.parentPaidList[i]['paid_add_qty'];
 	        	row.parentPaidList[i]['paid_no_out_qty'] = row.parentPaidList[i].paid_no_out_qty == null ? 0 : row.parentPaidList[i]['paid_no_out_qty'];
 	        	row.parentPaidList[i]['paid_use_yn'] = 'Y';
 	        	row.parentPaidList[i]['paid_add_doc_yn'] = 'N';
 	        	row.parentPaidList[i]['paid_doc_seq_no'] = row.parentPaidList[i].paid_doc_seq_no == null ? null : row.parentPaidList[i]['paid_doc_seq_no'];
 	        	row.parentPaidList[i]['paid_qty'] = row.parentPaidList[i].paid_add_qty;
 	        }

 	        for (var i = 0; i <row.parentFreeList.length; ++i) {
 	        	row.parentFreeList[i]['free_free_yn'] = "Y";
 	        	row.parentFreeList[i]['free_attach_yn'] = "N";
 	        	row.parentFreeList[i]['free_default_qty'] = row.parentFreeList[i].free_default_qty == null ? 0 : row.parentFreeList[i]['free_default_qty'];
 	        	row.parentFreeList[i]['free_add_qty'] = row.parentFreeList[i].free_add_qty == null ? 0 : row.parentFreeList[i]['free_add_qty'];
 	        	row.parentFreeList[i]['free_no_out_qty'] = row.parentFreeList[i].free_no_out_qty == null ? 0 : row.parentFreeList[i]['free_no_out_qty'];
 	        	row.parentFreeList[i]['free_use_yn'] = 'Y';
 	        	row.parentFreeList[i]['free_add_doc_yn'] = 'N';
 	        	row.parentFreeList[i]['free_doc_seq_no'] = row.parentFreeList[i].free_doc_seq_no == null ? null : row.parentFreeList[i]['free_doc_seq_no'];
 	        	row.parentFreeList[i]['free_qty'] = $M.toNum(row.parentFreeList[i].free_add_qty)+$M.toNum(row.parentFreeList[i].free_default_qty);
 	        }
        	var tempList = AUIGrid.exportToObject(auiGrid_part);
        	var partList = [];
        	var concatPartList = [];
        	for (var i = 0; i < tempList.length; ++i) {
        		if (tempList[i].part_attach_yn === "Y") {
        			partList.push(tempList[i]);
        		}
        	}
        	concatPartList = row.parentFreeList.concat(row.parentPaidList);
        	for (var i = 0; i < concatPartList.length; i++) {
    			var obj = new Object();
    			for (var prop in concatPartList[i]) {
    				var tempProp = "part"+prop.substring(4,prop.length);
    				obj[tempProp] = concatPartList[i][prop];
    			}
    			// 신규저장이기때문에 바로 삭제
    			if (obj.part_cmd != "D") {
    				partList.push(obj);
    			}
        	}
        	Array.isArray(partList) == true ? partList.sort($M.sortMulti("-part_no_out_qty")) : "";
        	AUIGrid.setGridData(auiGrid_part, partList);

        	// 신규저장이기 때문에 찍 처리 안함
			/* var prmArr = [];
			var pArr = AUIGrid.getGridData(auiGrid_part);
			for (var i = 0; i <  pArr.length; ++i) {
				if (pArr[i].part_cmd == "D") {
					prmArr.push(AUIGrid.rowIdToIndex(auiGrid_part, pArr[i]._$uid));
				}
			}
			AUIGrid.removeRow(auiGrid_part, prmArr); */

        	fnCalcNoOutQty();
        }

        function fnCalcNoOutQty() {
            var partLength = 0;
            var part = AUIGrid.getGridData(auiGrid_part);
            var noOutQty = 0;
            for (var i = 0; i < part.length; ++i) {
            	noOutQty += $M.toNum(part[i].part_no_out_qty);
            	if (part[i].part_cmd != "D") {
            		partLength+=1;
            	}
            }
            $("#part_total_cnt").html(partLength);
            $("#no_out_qty").html(noOutQty);
        }

		function goModelInfoClick() {
			if (isMachine == true && confirm("모델을 다시 조회하면 입력한 값이 초기화됩니다.\n다시 조회하시겠습니까?") == false) {
				return false;
			}
			var param = {
				/* s_machine_name : $M.getValue("machine_name"), */
				s_price_present_yn : "Y"
			};
			openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
		}

		function fnSetModelInfo(row) {
			var param = {
				machine_name : row.machine_name,
				machine_plant_seq : row.machine_plant_seq
			}
			$M.goNextPageAjax("/machine/stock/"+row.machine_plant_seq, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			 alert("모델을 변경했습니다.");
		    			 isMachine = true;
		    			 $M.setValue("machine_name", param.machine_name);
		    			 $M.setValue("machine_plant_seq", param.machine_plant_seq);
		    			 fnSetData(result);
					}
				}
			);
		}

		function fnSetData(result) {
			$("#btnAddPart").css("display", "block");
			// 선택사항
			optList = result.optionList;
			var optCode = $("#opt_code");
			optCode.html("");
			optCode.css("display", "none");
			AUIGrid.setGridData("#auiGrid_option", []);
			if (optList) {
				if (optList.length > 0) {
					optCode.css("display", "inline-block");
					var selectedOptCode = null;
					var selectedOptCodeIdx = 0;
					for (var i = 0; i < optList.length; ++i) {
						optCode.append("<option value='"+optList[i].opt_code+"'>"+optList[i].opt_name+"</option>");
						if (optList[i].opt_code == selectedOptCode) {
							selectedOptCodeIdx = i;
						}
					}
					if (selectedOptCode != null) {
						$M.setValue("opt_code", selectedOptCode);
					} else {
						$M.setValue("opt_code", optList[0].opt_code);
					}
					AUIGrid.setGridData("#auiGrid_option", optList[selectedOptCodeIdx].list);
				}
			}
			// 지급품목
			var partList = [];
			AUIGrid.setGridData("#auiGrid_part", []);
			if (result.freeList) {
				AUIGrid.setGridData("#auiGrid_part", result.freeList);
			}
			fnCalcNoOutQty();
		}

		function fnChangeOpt() {
			var opt = $M.getValue("opt_code");
			var tempOptList = [];
			for (var i = 0; i < optList.length; ++i) {
				if (optList[i].opt_code == opt) {
					tempOptList = optList[i].list;
				}
			}
			AUIGrid.setGridData("#auiGrid_option", tempOptList);
		}

		function fnSetOutAddr(row) {
			var param = {
				out_post_no : row.zipNo,
				out_addr1 : row.roadAddr,
				out_addr2 : row.addrDetail
			}
			$M.setValue(param);
		}

		function fnSetArrivalAddr(row) {
			var param = {
				arrival1_post_no : row.zipNo,
				arrival1_addr1 : row.roadAddr,
				arrival1_addr2 : row.addrDetail
			}
			$M.setValue(param);
		}

		function fnList() {
			//history.back();
			$M.goNextPage("/sale/sale0101");
		}

		function goRequestApproval() {
			if ($M.getValue("machine_plant_seq") == "") {
				alert("모델을 입력해주세요");
				$("#machine_name").focus();
				return false;
			}
			var param = {
				out_org_code : $M.getValue("out_org_code"),
				machine_plant_seq : $M.getValue("machine_plant_seq")
			}
			$M.goNextPageAjax(this_page+"/cnt", $M.toGetParam(param), {method : 'GET', loader : false},
					function(result) {
				    	if(result.success) {
				    		console.log(result);
				    		if (result.cnt == 0) {
				    			alert("출고센터에 장비가 없습니다.");
				    		} else {
				    			goSave('appr');
				    		}
						}
					}
				);
		}

		function goSave(appr) {
			if ($M.validation(document.main_form) == false) {
				return false;
			}
			var ti1 = $M.getValue("receive_plan_ti_1");
        	var ti2 = $M.getValue("receive_plan_ti_2");
        	if(ti1 == "00" && ti2 == "00") {
        		alert("희망시간을 선택하세요");
        		$("#receive_plan_ti_1").focus();
        		return false;
        	} else {
        		$M.setValue("receive_plan_ti", ti1+ti2);
        	}
			$M.setValue("save_mode", "save");
			var msg = "저장하시겠습니까?";
			if (appr != undefined) {
				$M.setValue("save_mode", "appr");
				msg = "결재 요청 하시겠습니까?\n요청 후 수정이 불가능 합니다";
			}

			if (AUIGrid.validation(auiGrid_memo) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			var frm = $M.toValueForm(document.main_form);
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid_option, auiGrid_part, auiGrid_memo];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxMsg(msg, this_page+"/save", gridFrm, {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		// 여기서 뒤로가기
			    		if (appr != undefined) {
							alert("처리가 완료됐습니다.");
							fnList();
			    		} else {
			    			alert("저장이 완료되었습니다.");
			    			fnList();
			    		}
					}
				}
			);
		}

		function fnSetDispOrgCd(row) {
			console.log(row);
			var param = {
				display_org_name : row.org_name,
				display_org_code : row.org_code
			}
			$M.setValue(param);
		}

		//그리드생성
		function createAUIGrid() {
			//그리드 생성 _ 지급품목
			var gridPros_product = {
				rowIdField : "_$uid",
				fillColumnSizeMode : false,
				headerHeight : 20,
				rowHeight : 11,
				footerHeight : 20,
			};
			var visibles = false;
			var columnLayout_product = [
				{
            		dataField : "_$uid",
            		visible : visibles
            	},
            	{
            		dataField : "part_seq_no",
            		visible : visibles
            	},
				{
					headerText : "부품번호",
					dataField : "part_part_no",
					width : "30%",
					style : "aui-center",
				},
				{
					headerText : "부품명",
					dataField : "part_part_name",
					style : "aui-left",
				},
				{
					headerText : "수량",
					dataField : "part_qty",
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "미출고",
					dataField : "part_no_out_qty",
					width : "10%",
					style : "aui-center",
				},
				{
                    dataField: "part_attach_yn",
                    visible: visibles
                },
                {
                    dataField: "part_add_doc_yn",
                    visible: visibles
                },
                {
                    dataField: "part_machine_doc_no",
                    visible: visibles
                },
                {
                    dataField: "part_doc_seq_no",
                    visible: visibles
                },
                {
                    dataField: "part_default_qty",
                    visible: visibles
                },
                {
                    dataField: "part_add_qty",
                    visible: visibles
                },
                {
                    dataField: "part_free_yn",
                    visible: visibles
                },
                {
                    dataField: "part_unit_price",
                    visible: visibles
                },
                {
                    dataField: "part_total_amt",
                    visible: visibles
                },
                {
                    dataField: "part_use_yn",
                    visible: visibles
                },
                {
                	dataField: "part_cmd",
                	visible: visibles
                }
			];
			auiGrid_part = AUIGrid.create("#auiGrid_part", columnLayout_product, gridPros_product);
			AUIGrid.setGridData(auiGrid_part, []);
			$("#auiGrid_part").resize();
			//그리드 생성 _ 선택사항
			var gridPros_option = {
				rowIdField : "part_no",
				fillColumnSizeMode : false,
				headerHeight : 20,
				rowHeight : 11,
				footerHeight : 20,
				height : 80
			};
			var columnLayout_option = [
				{
					dataField : "option_machine_plant_seq",
					visible : false
				},
				{
					dataField : "option_opt_code",
					visible : false
				},
				{
					headerText : "부품번호",
					dataField : "option_part_no",
					width : "20%",
					style : "aui-center",
				},
				{
					headerText : "부품명",
					dataField : "option_part_name",
					style : "aui-left",
				},
				{
					headerText : "수량",
					dataField : "option_qty",
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "미출고",
					dataField : "option_no_out_qty",
					width : "10%",
					style : "aui-center",
				}
			];
			auiGrid_option = AUIGrid.create("#auiGrid_option", columnLayout_option, gridPros_option);
			AUIGrid.setGridData(auiGrid_option, []);
			$("#auiGrid_option").resize();

			// 메모
			var gridPros_memo = {
				showStateColumn : true,
				fillColumnSizeMode : false,
				height : 130,
				editable : true,
			};
			var columnLayout_memo = [
				{
					dataField : "m_seq_no",
					visible : false
				},
				{
					dataField : "m_machine_doc_no",
					visible : false
				},
				{
					dataField : "m_mem_no",
					visible : false
				},
				{
                    dataField: "m_use_yn",
                    visible: false
                },
				{
					dataField : "gubun",
					headerText : "구분",
					editable : false,
					width : "8%",
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '출하'
					},
				},
				{
					dataField : "m_reg_mem_name",
					headerText : "작성자",
					editable : false,
					width : "8%",
				},
				{
					dataField : "m_memo_text",
					style : "aui-left",
					headerText : "특이사항",
					required : true,
					validator : AUIGrid.commonValidator,
					editable : true,
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "8%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid_memo);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrid_memo, "selectedIndex");
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
			auiGrid_memo = AUIGrid.create("#auiGrid_memo", columnLayout_memo, gridPros_memo);
			AUIGrid.setGridData(auiGrid_option, []);
			$("#auiGrid_memo").resize();
		}

		function fnAdd() {
			var obj = new Object();
			obj["m_mem_no"] = "${SecureUser.mem_no}";
			obj["m_memo_text"] = "";
			obj["m_use_yn"] = "Y";
			obj["m_reg_mem_name"] = "${SecureUser.user_name}";
			AUIGrid.addRow(auiGrid_memo, obj, 'last');
		}

    	function goPlanTiPopup() {
    		var planDt = $M.getValue("receive_plan_dt");
    		if (planDt == "") {
    			alert("출하 예정일자를 선택해주세요.");
    			$("#receive_plan_dt").focus();
    			return false;
    		}
    		var outOrgCode = $M.getValue("out_org_code");
    		// 센터가 지정되지않으면(기타센터) 모든 시간 가능 -> 출하지가 센터가 아니기때문에 시간관리 못함!
    		/* if (outOrgCode == "") {
    			alert("출하센터를 선택해주세요.");
    			$("#out_org_code").focus();
    			return false;
    		} */
        	var params = {
        		"parent_js_name" : "fnSetPlanTi",
   				"s_receive_plan_dt" : planDt,
   				"s_out_org_code" : outOrgCode,
   				"s_machine_out_doc_seq" : "${outDoc.machine_out_doc_seq}", // 같은 출하의뢰서면 취소했다가 다시 설정할 수 있도록함
   			}

   			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=480, left=0, top=0";
   			$M.goNextPage('/sale/sale0101p16', $M.toGetParam(params), {popupStatus: poppupOption});
    	}

    	function fnSetPlanTi(row) {
    		console.log(row);
    		var ti1 = row.code.substr(0, 2);
    		var ti2 = row.code.substr(2, 4);
    		$M.setValue("receive_plan_ti_1", ti1);
    		$M.setValue("receive_plan_ti_2", ti2);

    		var tempTi = ti1+"시 "+ti2+"분";
    		$M.setValue("receive_plan_ti_temp", tempTi);
    	}

    	// 업무DB 연결 함수 21-08-06이강원
     	function openWorkDB(){
     		openWorkDBPanel('',$M.getValue("machine_plant_seq"));
     	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="save_mode">
<input type="hidden" name="receive_plan_ti">
<input type="hidden" name="mch_type_cad" value="D"> <!-- 스탁은 건기농기 설정안하는데, 필수라서 D로 설정함 -->
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left approval-left" style="align-items: center;">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
<!-- 결재영역 -->
					<div>
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->
					<div class="row">
<!-- 좌측 폼테이블-->
						<div class="col-7">
							<div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
								<div class="title-wrap">
									<h4>기본정보</h4>
									<div class="btn-group">
										<div class="right">${stock.reg_date } ${stock.reg_mem_no }</div>
									</div>
								</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
								<table class="table-border mt5">
									<colgroup>
										<col width="75px">
										<col width="">
										<col width="75px">
										<col width="">
									</colgroup>
									<tbody>
										<tr>
											<th class="text-right">관리번호</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-3">
														<input type="text" class="form-control" readonly="readonly" value="MC${inputParam.s_current_year}">
													</div>
													<div class="col-auto">-</div>
													<div class="col-2">
														<input type="text" class="form-control" readonly="readonly">
													</div>
												</div>
											</td>
											<th class="text-right">상태</th>
											<td>
												작성중
											</td>
										</tr>
										<tr>
											<th class="text-right rs">모델명</th>
											<td>
												<div class="form-row inline-pd pr">
													<div class="col-auto">
														<div class="input-group">
															<input type="text" class="form-control border-right-0 width120px" name="machine_name" id="machine_name" value="${stock.machine_name }" readonly="readonly" required="required" alt="모델명">
															<input type="hidden" name="machine_plant_seq" id="machine_plant_seq">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goModelInfoClick();"><i class="material-iconssearch"></i></button>
														</div>
													</div>
													<div class="col-auto">
														<c:if test="${page.fnc.F00114_001 eq 'Y'}">
					                                    	<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();")>업무DB</button>
					                                    </c:if>
					                                </div>
												</div>
											</td>
											<th class="text-right rs">전시점</th>
											<td>
												<div class="input-group">
													<input type="text" class="form-control border-right-0 width120px" id="display_org_name" name="display_org_name" value="${stock.display_org_name}" readonly="readonly" required="required" alt="전시점">
													<input type="hidden" name="display_org_code" id="display_org_code">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapPanel('fnSetDispOrgCd');"><i class="material-iconssearch"></i></button>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right rs">인도예정</th>
											<td>
												<div class="input-group">
													<input type="text" class="form-control border-right-0 rb calDate width120px" id="receive_plan_dt" name="receive_plan_dt" value="${stock.receive_plan_dt}" dateFormat="yyyy-MM-dd" required="required" alt="인도예정" onchange="fnChangeOutOrgCode()">
													<select class="form-control width100px" style="margin-left: 5px; border-radius: 4px;" name="out_org_code" id="out_org_code" onchange="fnChangeOutOrgCode()">
														<c:forEach var="item" items="${outOrgCodeList}">
		                                                    <option value="${item.org_code}">
		                                                            ${item.org_name}
		                                                    </option>
		                                                </c:forEach>
													</select>

												</div>
											</td>
											<th class="text-right">인수자</th>
											<td>
												<input type="text" class="form-control width120px" name="receive_user_name" id="receive_user_name" value="${stock.receive_user_name }" maxlength="30">
											</td>
										</tr>
										<tr>
											<th class="text-right rs">희망시간</th>
											<td>
												<div class="input-group">
													<c:if test="${not empty stock.receive_plan_ti}">
			                                			<input type="text" class="form-control border-right-0" style="max-width: 76px;" id="receive_plan_ti_temp" name="receive_plan_ti_temp" required="required" readonly="readonly" value="${fn:substring(stock.receive_plan_ti,0,2)}시 ${fn:substring(stock.receive_plan_ti,2,4)}분">
			                                		</c:if>
			                                		<c:if test="${empty stock.receive_plan_ti}">
			                                			<input type="text" class="form-control border-right-0" style="max-width: 76px;" id="receive_plan_ti_temp" name="receive_plan_ti_temp" required="required" readonly="readonly" value="">
			                                		</c:if>
			                                   		<input type="hidden" id="receive_plan_ti_1" name="receive_plan_ti_1" value="${fn:substring(stock.receive_plan_ti,0,2) }">
			                                   		<input type="hidden" id="receive_plan_ti_2" name="receive_plan_ti_2" value="${fn:substring(stock.receive_plan_ti,2,4) }">
			                                   		<button type="button" class="btn btn-icon btn-primary-gra" id="breg_search_btn" onclick="javascript:goPlanTiPopup()"><i class="material-iconssearch"></i></button>
			                                    </div>
											</td>
											<th class="text-right">연락처</th>
											<td>
												<input type="text" class="form-control width120px" id="receive_user_tel_no" name="receive_user_tel_no" format="tel" value="${stock.receive_user_tel_no}" maxlength="11">
											</td>
										</tr>
										<tr>
											<th class="text-right rs">출하지</th>
											<td colspan="3">
												<div class="form-row inline-pd">
													<div class="col-1 pdr0">
														<input type="text" class="form-control mw45" id="out_post_no" name="out_post_no" value="${stock.out_post_no}" readonly="readonly" required="required" alt="출하지">
													</div>
													<div class="col-auto pdl5">
														<button type="button" class="btn btn-primary-gra" style="width: 100%;"  onclick="javascript:openSearchAddrPanel('fnSetOutAddr');">주소찾기</button>
													</div>
													<div class="col-5">
														<input type="text" class="form-control" id="out_addr1" name="out_addr1" value="${stock.out_addr1 }" readonly="readonly">
													</div>
													<div class="col-4">
														<input type="text" class="form-control" id="out_addr2" name="out_addr2" value="${stock.out_addr2 }">
													</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right rs">도착지</th>
											<td colspan="3">
												<div class="form-row inline-pd">
													<div class="col-1 pdr0">
														<input type="text" class="form-control mw45" id="arrival1_post_no" name="arrival1_post_no" value="${stock.arrival1_post_no }" readonly="readonly" required="required" alt="도착지 우편번호">
													</div>
													<div class="col-auto pdl5">
														<button type="button" class="btn btn-primary-gra" style="width: 100%;"  onclick="javascript:openSearchAddrPanel('fnSetArrivalAddr');">주소찾기</button>
													</div>
													<div class="col-5">
														<input type="text" class="form-control" id="arrival1_addr1" name="arrival1_addr1" value="${stock.arrival1_addr1 }" readonly="readonly">
													</div>
													<div class="col-4">
														<input type="text" class="form-control" id="arrival1_addr2" name="arrival1_addr2" value="${stock.arrival1_addr2 }">
													</div>
												</div>
											</td>
										</tr>
									</tbody>
								</table>
							</div>

							<div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
								<div class="title-wrap mt10">
									<div class="title-sum">
										<h4>지급품목</h4>
										<div>전체 <span id="part_total_cnt">0</span>건 중 <span class="text-secondary"><span id="part_no_out_cnt">0</span>건</span>과부족</div>
									</div>
									<div>
										<button type="button" id="btnAddPart" style="display: none;" class="btn btn-default" onclick="javascript:goAddPartPopup()">추가출고처리</button>
									</div>
								</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
								<div id="auiGrid_part" style="margin-top: 5px;"></div>
							</div>

							<div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
							<div class="title-wrap mt10">
								<h4>옵션품목</h4>
								<div class="btn-group">
									<div class="right">
										<select name="opt_code" id="opt_code" style="height: 24px; display: none;" onchange="fnChangeOpt()"></select>
									</div>
								</div>
							</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
							<div id="auiGrid_option" style="margin-top: 5px;"></div>
							</div>

						</div>
<!-- 좌측 폼테이블-->
<!-- 우측 폼테이블-->
						<div class="col-5">
<!-- 출하사항 -->
							<div class="process2">
								<div class="title-wrap">
									<h4>출하사항</h4>
								</div>
								<table class="table-border mt5">
									<colgroup>
										<col width="25%">
										<col width="25%">
										<col width="25%">
										<col width="25%">
									</colgroup>
									<tbody>
										<tr>
											<th class="text-right">차대번호</th>
											<td colspan="3">
												<div class="form-row inline-pd">
													<div class="col-6">
														<div class="input-group">
															<input type="text" class="form-control border-right-0">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:alert('차대번호 조회');"><i class="material-iconssearch"></i></button>
														</div>
													</div>
													<div class="col-6">
														<input type="text" class="form-control">
													</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">운송구분</th>
											<td>
												<select class="form-control">
													<option>선택</option>
													<option>선택</option>
												</select>
											</td>
											<th class="text-right">출고일자</th>
											<td>
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate">
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">도착일자</th>
											<td>
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" disabled="disabled"/>
												</div>
											</td>
											<th class="text-right">도착일시</th>
											<td>
			                                <div class="form-row inline-pd">
			                                   <div class="col-4">
			                                       <select class="form-control width50px p2b" >
			                                           <option value="00">00</option>
			                                       </select>
			                                   </div>
			                                   <div class="col-1">
			                                       	시
			                                   </div>
			                                   <div class="col-4" style="padding-left: 5px">
			                                       <select class="form-control width50px p2b">
			                                           <option value="00">00</option>
			                                       </select>
			                                   </div>
			                                   <div class="col-1">
			                                       	분
			                                   </div>
			                               </div>
			                            </td>
										</tr>
										<tr>
											<th class="text-right">도착지</th>
											<td colspan="3">
												<input type="text" class="form-control">
											</td>
										</tr>
										<tr>
											<th class="text-right">운송사</th>
											<td>
												<select class="form-control">
													<option>선택</option>
													<option>선택</option>
												</select>
											</td>
											<th class="text-right">연락처</th>
											<td>
												<input type="text" class="form-control">
											</td>
										</tr>
										<tr>
											<th class="text-right">운임</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
											<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
											<%--<th class="text-right">대리점운임</th>--%>
											<th class="text-right">위탁판매점운임</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">출하시특이사항</th>
											<td colspan="3">
												<textarea class="form-control" style="height: 100px;" ></textarea>
											</td>
										</tr>
									</tbody>
								</table>
							</div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
							<div class="title-wrap mt10">
								<h4>특이사항</h4>
								<div>
									<button type="button" id="_fnAdd" class="btn btn-default" onclick="javascript:fnAdd();"><i class="material-iconsadd text-default"></i>행추가</button>
								</div>
							</div>
							<div id="auiGrid_memo" style="margin-top: 5px; width: 100%"></div>
							</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->


<!-- 우측 폼테이블-->

					</div>
<!-- /폼테이블 -->

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->

				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
