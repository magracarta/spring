<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 부품연관팝업 > 부품연관팝업 > null > 부품조회
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var checkGridData;
		var confirmYn = "${inputParam.confirm_yn}";
		$(document).ready(function() {
			// readonly
			fnSetReadOnly('${inputParam.partReadOnlyField}'.split(','));

			createAUIGrid();
			// 단일 선택 시 적용 버튼 숨김
			if('${inputParam.multi_yn}' == 'N') {
				if($(".btn-info").html() == '적용') {
					$("#btnHide").children().eq(0).attr('id','btnApply');
			       	$("#btnApply").css({
			            display: "none"
			        });
				}
			}
			// 매입처, 부품그룹 셋팅
			var partMngCdStr = "${inputParam.s_part_mng_cd_str}";
			var partMngCd = partMngCdStr != "" ? partMngCdStr.split("#")[0] : "${inputParam.s_part_mng_cd}";
			$M.setValue("s_cust_no", "${inputParam.s_cust_no}");
			$M.setValue("s_part_group_cd", "${inputParam.s_part_group_cd}");
			<%--$M.setValue("s_part_mng_cd", "${inputParam.s_part_mng_cd}");--%>
			$M.setValue("s_part_mng_cd", partMngCd);
			$M.setValue("s_cust_name", "${inputParam.s_cust_name}");
			$M.setValue("s_part_group_name", "${inputParam.s_part_group_name}");

			// 창고구분 세팅
			if ('${inputParam.s_warehouse_cd}' != ''){
				$M.setValue("s_warehouse_cd", "${inputParam.s_warehouse_cd}");
			}

			$M.setValue("s_only_warehouse_yn", "${inputParam.s_only_warehouse_yn}");

			// 권한자가 아닐 시 입고단가 보이지 않게 처리
			if(${page.add.IN_PRICE_SHOW_YN ne 'Y'}) {
				AUIGrid.hideColumnByDataField(auiGrid, ["in_stock_price"] ); // 숨길대상
			}

			// 창고재고만 조회하는 경우
			if ('${inputParam.s_only_warehouse_yn}' == 'Y'){
				// 창고정보를 넘겨받지 않은 경우
				if ('${inputParam.s_warehouse_cd}' == ''){
					AUIGrid.hideColumnByDataField(auiGrid, ["part_warehouse_current", "storage_name","warehouse_name"] ); // 숨길대상
				}
			}
			else{
				// 창고정보를 넘겨받지 않은 경우
				if ('${inputParam.s_warehouse_cd}' == ''){
					AUIGrid.hideColumnByDataField(auiGrid, ["part_warehouse_current", "storage_name","warehouse_name"] ); // 숨길대상
				}
			}


			if ('${inputParam.s_part_no}' != ''){
				goSearch();
			}
		});

		//조회
		function goSearch() {
			var stock_mon = '${inputParam.s_current_mon}';
			var params = AUIGrid.getGridData(auiGrid);
			var param = {
					"stock_mon" : stock_mon,
					"s_sort_key" : "tp.part_no",
					"s_sort_method" : "desc",
					"s_cust_no" : $M.getValue("s_cust_no"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_part_group_cd" : $M.getValue("s_part_group_cd"),
					"s_part_group_name" : $M.getValue("s_part_group_name"),
					"s_part_no" : $M.getValue("s_part_no"),
 					"s_part_name" : $M.getValue("s_part_name"),
					"s_warehouse_cd" : $M.getValue("s_warehouse_cd"),
					"s_only_warehouse_yn" : $M.getValue("s_only_warehouse_yn"),
					"s_part_mng_cd" : $M.getValue("s_part_mng_cd"),
					"s_part_mng_cd_str" : $M.getValue("s_part_mng_cd_str"),
					"s_not_sale_yn" : $M.getValue("s_not_sale_yn"),
					"s_not_in_yn" : $M.getValue("s_not_in_yn"),
					"s_not_in_yn" : $M.getValue("s_not_in_yn"),
					"s_deal_cust_no" : "${inputParam.s_deal_cust_no}",
					"s_disposal_yn" : $M.getValue("s_disposal_yn") == "Y" ? "Y" : "N", // [정윤수] 23.04.13 장기/충당/폐기부품관리 페이지에서 폐기대상으로 마스터 반영된 부품 조회하기위함
			};

			console.log(param, "param");
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_part_no", "s_part_name", "s_part_mng_cd"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}

		function createAUIGrid() {
			if('${inputParam.multi_yn}' == 'Y'){
				var gridPros = {
						// rowIdField 설정
						rowIdField : "part_no",
						// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
						wrapSelectionMove : false,
						//체크박스 출력 여부
						showRowCheckColumn : true,
						//전체선택 체크박스 표시 여부
						showRowAllCheckBox : true,
						// rowNumber
						showRowNumColumn: true,
						editable : false,
						headerHeight : 40
				};
			} else {
				var gridPros = {
						// rowIdField 설정
						rowIdField : "part_no",
						// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
						wrapSelectionMove : false,
						// rowNumber
						showRowNumColumn: true,
						editable : false,
						headerHeight : 40
					};
			};
			var columnLayout = [
				{
					dataField : "unit_price",
					headerText : "단가",
					visible:false
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : 100,
					style : "aui-center"
				},
				{
					headerText : "신번호",
					dataField : "part_new_no",
					width : 80,
					style : "aui-center"
				},
				{
					headerText : "신번호호환",
					dataField : "part_new_exchange_cd",
					width : 80,
					style : "aui-center"
				},
				{
					headerText : "구번호",
					dataField : "part_old_no",
					width : 80,
					style : "aui-center",
				},
				{
					headerText : "부품호환",
					dataField : "part_old_exchange_cd",
					width : 60,
					style : "aui-center",
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					width : 170,
					style : "aui-left"
				},
				{
					dataField : "part_storage_seq",
					visible : false
				},
				{
					dataField : "warehouse_cd",
					visible : false
				},
				{
					dataField : "part_avg_price",
					visible : false
				},
				{
					dataField : "part_buy_price",
					visible : false
				},
				{
					dataField : "sale_mi_qty",
					visible : false
				},
				{
					headerText : "가용재고<br>(전체)",
					dataField : "part_current",
					width : 70,
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "현재고<br>(소속창고)",
					dataField : "part_warehouse_current",
					width : 70,
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "가용재고<br>(소속창고)",
					dataField : "part_able_stock",
					width : 70,
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "저장위치<br>(소속창고)",
					dataField : "storage_name",
					width : 100,
					style : "aui-center"
				},
				// { // 22.11.18 Q&A 15566 컬럼명 변경
				// 	headerText : "소속창고",
				// 	dataField : "warehouse_name",
				// 	width : 80,
				// 	style : "aui-center"
				// },
				// {
				// 	headerText : "관리구분<br>코드",
				// 	dataField : "part_mng_cd",
				// 	width : 60,
				// 	style : "aui-center"
				// },
	 			{
					headerText : "부품구분",
					dataField : "part_mng_name",
					width : 80,
					style : "aui-center",
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if(item["part_mng_name"] != "정상부품") {
							var template = '<div>' + '<span style="color:red";>' + item.part_mng_name + '</span>' + '</div>';
							return template;
						} else {
						   var template = '<div>' + '<span style="color:black";>' + item.part_mng_name + '</span>' + '</div>';
						   return template;
						}
					}
				},
	 			{
					headerText : "입고단가",
					dataField : "in_stock_price",
					dataType : "numeric",
					formatString : "#,##0",
					width : 85,
					style : "aui-right"
				},
				{
					dataField : "cust_price",
					visible : false
				},
				{
					headerText : "VIP가<br>(VAT별도)",
					dataField : "vip_sale_price",
					dataType : "numeric",
					formatString : "#,##0",
					width : 85,
					style : "aui-right"
				},
				{
					headerText : "VIP가<br>(VAT포함)",
					dataField : "vip_sale_vat_price",
					dataType : "numeric",
					formatString : "#,##0",
					width : 85,
					style : "aui-right"
				},
				{
					headerText : "일반가<br>(VAT별도)",
					dataField : "sale_price",
					dataType : "numeric",
					formatString : "#,##0",
					width : 85,
					style : "aui-right"
				},
				{
					headerText : "당해판매",
					dataField : "part_year",
					width : 75,
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "전년판매",
					dataField : "part_before1",
					width : 75,
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "전전년판매",
					dataField : "part_before2",
					width : 75,
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					dataField : "part_name_change_yn",
					visible : false
				},
				{
					dataField : "current_stock",
					visible : false
				},
				{
					headerText : "이동요청",
					dataField : "transBtn",
					width : "70",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var param = {
									"part_no" : event.item["part_no"]

							};
							openTransPartPanel('setMovePartInfo', $M.toGetParam(param));
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '이동요청'
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "warning_text",
					visible : false,
				}
			]
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if('${inputParam.multi_yn}' == 'N'){
					// Row행 클릭 시 반영
					try{
						if("${inputParam.use_type}" == "part_order" && event.item["part_mng_cd"] == "8"){ // 2022.10.19 15267 부품발주요청시 비 부품 선택 시 alert 호출
							alert("비 부품은 발주요청이 불가능 합니다.");
							return false;
						}else{
							opener.${inputParam.parent_js_name}(event.item);
							window.close();
						}
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
				} else {
					// Row행 클릭 시 반영
					try{
						// 2020-11-11 다중선택 셀클릭시 부모창에 적용되도록 변경작업 (중복시 부모창에서 return하는 메시지 출력) by 황빛찬, 박예진
						// 23.02.28 정윤수 부품발주 부품추가 시 정상재고 아닌 경우 확인창 띄움
						if(event.item["part_mng_cd"] != "1" && confirmYn == 'Y'){
							if(confirm("정상재고가 아닌 부품이 선택되었습니다. ("+event.item["part_no"]+")\n추가 하시겠습니까?") == false){
								return false;
							}
						}
						var item = [];
						item.push(event.item);
						if('${inputParam.s_warning_check}' != 'Y'){
							if(opener.${inputParam.parent_js_name}(item) != undefined) {
								alert(opener.${inputParam.parent_js_name}(item));
								return false;
							}
						}else{
							if(opener.${inputParam.parent_js_name}) {
								item[0].multi_check  = 'Y';
								var warningText = opener.${inputParam.parent_js_name}(item);
								if(warningText != undefined){
									alert(warningText);
									return false;
								}
							}
						}

					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
					// 다중선택시 셀클릭 이벤트 바인딩
// 					AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
				};
			});
			$("#auiGrid").resize();
		}

		function setMovePartInfo() {

		}

		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			var item = event.item, rowIdField, rowId;
			rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
			rowId = item[rowIdField];
			// 이미 체크 선택되었는지 검사
			if(AUIGrid.isCheckedRowById(event.pid, rowId)) {
				// 엑스트라 체크박스 체크해제 추가
				AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
			} else {
				// 엑스트라 체크박스 체크 추가
				AUIGrid.addCheckedRowsByIds(event.pid, rowId);
			}
		};

		//적용
		function goApply() {
			// 2020-11-11 다중선택 셀클릭시 부모창에 적용되도록 변경작업 (중복시 부모창에서 return하는 메시지 출력) by 황빛찬, 박예진
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			if('${inputParam.s_warning_check}' != 'Y'){
				for (var i = 0; i < itemArr.length; i++) {
					// 23.02.28 정윤수 부품발주 부품추가 시 정상재고 아닌 경우 확인창 띄움
					if(itemArr[i].part_mng_cd != "1" && confirmYn == 'Y'){
						if(confirm("정상재고가 아닌 부품이 선택되었습니다. ("+itemArr[i].part_no+")\n계속 진행 하시겠습니까?") == false){
							return;
						}
						confirmYn = "N";
					}
					var item = [];
					item.push(itemArr[i]);
					if(opener.${inputParam.parent_js_name}(item) != undefined) {
						alert(opener.${inputParam.parent_js_name}(item));
						return false;
					};
				}
			}else{
				if(opener.${inputParam.parent_js_name}) {
					opener.${inputParam.parent_js_name}(itemArr);
				};
			}

			window.close();
		}

		//매입처 조회 test
		function setSearchClientInfo(row) {
			alert(JSON.stringify(row));
		}

		function fnClose() {
			window.close();
		}

		// 렌탈기본정보에서 부품간편등록
		function goAddRentalPart() {
			var inputString = prompt('렌탈어테치명을 입력하세요.', '');
			if (inputString != null) {
				var param = {
					part_name : inputString.toUpperCase()
				}
				$M.goNextPageAjaxSave(this_page + '/rental/save', $M.toGetParam(param), {method : 'post'},
						function(result) {
							if(result.success) {
								alert("처리가 완료되었습니다.");
								$M.setValue("part_name", param.part_name);
								goSearch();
							} else {
								setTimeout(function() {
									goAddRentalPart();
								}, 1);
							}
						}
					);
			}
		}

</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="s_part_mng_cd_str" name="s_part_mng_cd_str" value="${inputParam.s_part_mng_cd_str}">
<!-- 팝업 -->
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
    <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
<!-- /타이틀영역 -->
    <div class="content-wrap">
<!-- 검색조건 -->
		<div class="search-wrap">
			<table class="table">
				<colgroup>
					<col width="50px" class="dpn">
					<col width="150px" class="dpn">
					<col width="60px" class="dpn">
					<col width="150px" class="dpn">
					<col width="60px">
					<col width="120px">
					<col width="50px">
					<col width="120px">
					<col width="70px">
					<col width="100px">
					<col width="90px">
					<col width="140px">
					<col width="70px">
					<col width="140px">
					<col width="80px">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th class="dpn">매입처</th>
						<td class="dpn">
							<div class="input-group">
								<input type="text" style="width : 150px;" class="form-control border-right-0"
								id="s_cust_no"
								name="s_cust_no"
								easyui="combogrid"
								header="Y"
								easyuiname="clientCode"
								panelwidth="350"
								maxheight="155"
								textfield="code_name"
								enter="goSearch()"
								multi="N"
								idfield="code" />
							</div>
						</td>
						<th class="dpn">부품그룹</th>
						<td class="dpn">
							<div class="input-group">
								<input type="text" style="width : 150px;" class="form-control border-right-0"
								id="s_part_group_cd"
								name="s_part_group_cd"
								easyui="combogrid"
								header="Y"
								easyuiname="groupCode"
								panelwidth="360"
								maxheight="155"
								textfield="code_name"
								multi="N"
								enter="goSearch()"
								idfield="code" />
							</div>
						</td>
						<th>부품번호</th>
						<td>
							<div class="icon-btn-cancel-wrap">
								<input type="text" name="s_part_no" id="s_part_no" class="form-control" value="${inputParam.s_part_no}" placeholder="부품번호">
							</div>
						</td>
 						<th>부품명</th>
 						<td>
							<div class="icon-btn-cancel-wrap">
								<input type="text" name="s_part_name" id="s_part_name" class="form-control" value="${inputParam.s_part_name}">
							</div>
						</td>
						<th>부품구분</th>
						<td>
							<select class="form-control" name="s_part_mng_cd" id="s_part_mng_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['PART_MNG']}">
									<c:if test="${item.code_value ne '0' && item.code_value ne '9'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">매출정지 여부</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="s_not_sale_y" name="s_not_sale_yn" value="Y" checked="checked">
								<label class="form-check-label" for="s_not_sale_y">제외</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="s_not_sale_n" name="s_not_sale_yn" value="N">
								<label class="form-check-label" for="s_not_sale_n">제외안함</label>
							</div>
						</td>
						<th class="text-right">미수입 여부</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="s_not_in_y" name="s_not_in_yn" value="Y" checked="checked">
								<label class="form-check-label" for="s_not_in_y">제외</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="s_not_in_n" name="s_not_in_yn" value="N">
								<label class="form-check-label" for="s_not_in_n">제외안함</label>
							</div>
						</td>
						<td>
							<input type="checkbox" id="s_disposal_yn" name="s_disposal_yn" value="Y"/><label for="s_disposal_yn">폐기대상</label> 
						</td>
						<td class="">
							<button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch()">조회</button>
							<c:if test="${'Y' eq inputParam.s_search_rental_part_yn}">
								<button type="button" class="btn btn-important" style="width: 130px;" onclick="javascript:goAddRentalPart()">렌탈어테치 간편등록</button>
							</c:if>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
<!-- /검색조건 -->
<!-- 검색결과 -->

		<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>

		<div class="btn-group mt5">
			<div class="left">
				총 <strong class="text-primary" id="total_cnt">0</strong>건
			</div>
			<div class="right" id="btnHide">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
<!-- /검색결과 -->
    </div>
</div>
<!-- /팝업 -->
</form>
</body>
</html>